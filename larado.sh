#!/bin/bash

# Variables initialization ___________
_apath=$(pwd)
_dirName=${_apath##*/} 
#_apath="$_apath:C:=/c%"
#_apath="$_apath:\=/%"
_args=$@
_command=
_hpath=
_cpath="/app"
_mount="--mount type=bind,src=$_apath,dst=/app"
_network="--network larado-net"

#FOR %%I in (.) do SET _dirName=%%~nxI
_dockerMysql="larado-mysql-$_dirName"

#_____ Options parsing
parseOptions() {
	if [[ $1 == "-m" ]]; then 
		echo "Options mount:"
		parseMount $@
	fi
}
parseMount() {
	shift
	if [[ -z $1 ]]; then echo "Invalid arguments for -m option"
	else
		_hpath=$1
		shift
		if [[ -n $1 ]]; then 
			_cpath=$1
			shift
		fi
		_mount="$_mount --mount type=bind,src=$_hpath,dst=$_cpath"
		echo " - Mount $_hpath to $_cpat"
	fi
	_args=$@
}

#_____ Command selection
cmd() {
	_command=$1
	shift
	if 	 [[ "$_command" == "new" ]]; 			then cmdNew $@
	elif [[ "$_command" == "composer" ]]; 		then cmdComposer $@
	elif [[ "$_command" == "artisan" ]]; 		then cmdArtisan $@
	elif [[ "$_command" == "serve" ]]; 			then cmdServe $@
	elif [[ "$_command" == "web-start" ]]; 		then serverStart $@
	elif [[ "$_command" == "web-stop" ]]; 		then serverStop $@
	elif [[ "$_command" == "web-clean" ]]; 		then serverClean $@
	elif [[ "$_command" == "mysql-start" ]]; 	then mysqlStart $@
	elif [[ "$_command" == "mysql-stop" ]]; 	then mysqlStop $@
	elif [[ "$_command" == "mysql-clean" ]]; 	then mysqlClean $@
	elif [[ "$_command" == "npm" ]]; 			then nodeRunNpm $@
	elif [[ "$_command" == "migrate" ]]; 		then cmdMigrate $@
	elif [[ "$_command" == "stop" ]]; 			then cmdStop $@
	elif [[ "$_command" == "clean" ]]; 			then cmdClean $@
	elif [[ "$_command" == "recreate" ]]; 		then cmdRecreate $@
	elif [[ "$_command" == "infos" ]]; 			then cmdInfos $@
	elif [[ "$_command" == "cache" ]]; 			then cmdCache $@
	elif [[ "$_command" == "setup" ]]; 			then cmdSetup $@
	elif [[ "$_command" == "net-create" ]]; 	then networkCreate
	else echo " -- Unknown or missing action"
	fi
}


#_____ New Project
cmdNew() {
	if [[ -z $1 ]]; then 
		echo "-- Missing project name"
	else
		echo "larado : Creating new project $1"
		docker run --rm -i -t $_mount composer create-project --prefer-dist laravel/laravel $1
	fi
}
#_____ Composer
cmdComposer() {
	echo "larado : composer $*"
	docker run --rm -i -t $_mount composer $*
}
#_____ Artisan 
cmdArtisan() {
	echo "larado : artisan $@"
	docker run --rm -i -t $_mount $_network efynox/laravel-artisan $@
	sudo chown -R $(whoami) .
}
#_____ Artisan 
cmdCache() {
	echo "larado : cache"
	echo "Cleaning composer"
	docker run --rm -i -t $_mount composer -v dump-autoload
	echo "Cleaning laravel"
	docker run --rm -i -t $_mount $_network efynox/laravel-artisan view:clear
	docker run --rm -i -t $_mount $_network efynox/laravel-artisan route:clear
}
#_____ Artisan 
cmdSetup() {
	echo "larado : setup"
	sudo cp larado.sh /opt/bin/larado
}
#_____ Serve 
cmdServe() {
	echo "-- Network : Creating "
	docker network create larado-net

	mysqlStart

	serverStart

	echo "-- -- -- -- -- -- -- -- -- -- -- -- --"
	echo "Host ready at : $(docker-machine ip)  "
	echo "-- -- -- -- -- -- -- -- -- -- -- -- --"
}
#_____ Migrate
cmdMigrate() {
	mysqlMigrate
}
#_____ Stop
cmdStop() {
	echo "larado : stop"
	serverStop
	mysqlStop
}
#_____ Clean
cmdClean() {
	echo "larado : clean"
	serverClean
	mysqlClean
}
#_____ Recreate
cmdRecreate() {
	echo "larado : recreate"
	serverStop
	serverClean

	mysqlStop
	mysqlClean

	mysqlStart
	serverStart
}
#_____ Infos
cmdInfos() {
	echo "larado : infos"
	docker run --rm -i -t --entrypoint=php efynox/laravel-artisan -i
}

# __MYSQL___BEG________________________
mysqlStart() {
	echo "-- MySQL : Checking container status"
	# If an other mysql container is running, we stop it
	if docker ps --filter "label=larado.mysql" --format "{{.ID}}" | grep "running" >> larado.out
	then
		mysqlStop
	fi
	# If the mysql container of this app already exist, we restart it. Otherwise, we create a new one
	if docker inspect $_dockerMysql | grep "running" >> larado.out
	then 
		if docker inspect $_dockerMysql | grep "running" >> larado.out
		then
			echo "MySQL container already running"
		else
			mysqlRestart
		fi
	# Else, we a creat
	else
		mysqlCreate
	fi
	#((docker ps --filter "label=larado.mysql" --format "{{.ID}}") && (docker inspect $_dockerMysql | find "running")) || mysqlStop
	#if (docker inspect $_dockerMysql); then echo "MySQL container not found, creating new one" fi
	# || mysqlCreate
	#(docker inspect $_dockerMysql | grep "running") || mysqlRestart
	#(docker inspect $_dockerMysql | grep "running") && echo "MySQL is already running"
}
mysqlRestart() {
	echo "-- MySQL : Restarting container"
	docker start $_dockerMysql
}
mysqlCreate() {
	echo "-- MySQL : Creating container"
	docker run -i -t -d --name $_dockerMysql -e "MYSQL_DATABASE=laravel" -e "MYSQL_USER=laravel" -e "MYSQL_PASSWORD=test" -e "MYSQL_RANDOM_ROOT_PASSWORD=yes" $_network --network-alias db --label "larado.mysql=yes" mysql --default-authentication-plugin=mysql_native_password
	# -p 3306:3306

	echo "-- MySQL : Waiting container to be ready"
	(docker logs $_dockerMysql | grep "ready" | grep "3306")

	mysqlMigrate
	mysqlSeed
}
mysqlMigrate() {
	echo "-- MySQL : Running migrations"
	docker run --rm -i -t $_mount $_network efynox/laravel-artisan migrate
}
mysqlSeed() {
	echo "-- MySQL : Seeding database"
	docker run --rm -i -t $_mount $_network efynox/laravel-artisan db:seed
}
mysqlStop() {
	echo "-- MySQL : Stopping current container"
	#for /f eol^= %%A in ('docker ps --filter "label=larado.mysql" --format "{{.ID}}"') do docker stop %%A
	docker stop $_dockerMysql
}
mysqlClean() {
	echo "-- MySQL : Cleaning container"
	docker rm $_dockerMysql
}
# __MYSQL___END________________________

#_____ SERVER _________________________
serverStart() {
	echo "-- Server : Checking container status"
	(docker inspect larado-server | grep "running") && serverStop
	(docker inspect larado-server | grep "exited") && serverClean

	serverCreate

#	serverCron
	
	echo "-- Server : Starting logs"
	docker logs larado-server
}
serverStop() {
	echo "-- Server : Stopping current container"
	docker stop larado-server
}
serverClean() {
	echo "-- Server : Cleaning container"
	docker rm larado-server
}
serverCreate() {
	echo "-- Server : Creating container"
	docker run -i -t -d --name larado-server -p 8000:8000 $_mount $_network efynox/laravel-artisan serve --host=0.0.0.0 --port=8000
}
serverCron() {
	echo " -- Server : Adding cron tasks"
	#docker exec larado-server bash /root/create-cron.sh
}

#_____ NETWORK _________________________
networkCreate() {
	docker network create larado-net
}

#_____ NODE.js _________________________
nodeRunNpm() {
	docker run --rm -i -t $_mount $_network --workdir /app node npm $@ 
}

#______________
parseOptions $@

cmd $_args