@ECHO OFF
SET string=%CD%
SET string=%string:C:=/c%
SET string=%string:\=/%
SET args=

IF "%1" EQU "new" GOTO :cmdNew
IF "%1" EQU "composer" GOTO :cmdComposer
IF "%1" EQU "artisan" GOTO :cmdArtisan
IF "%1" EQU "serve" GOTO :cmdServe
IF "%1" EQU "stop" GOTO :cmdStop
IF "%1" EQU "clean" GOTO :cmdClean
IF "%1" EQU "recreate" GOTO :cmdRecreate
IF "%1" EQU "infos" GOTO :cmdInfos
ECHO -- Unknown or missing action
GOTO :end

:: _ New Project _____________________
:cmdNew
	IF [%2] EQU [] GOTO :cmdNew_Err
	ECHO larado : Creating new project "%2
	docker run --rm -i -t --mount type=bind,src=%string%,dst=/app composer create-project --prefer-dist laravel/laravel %2
	GOTO :end

:cmdNew_Err
	ECHO -- Missing project name
	GOTO :end

:: _ Composer _________________________
:cmdComposer
	IF DEFINED %1 THEN (
    	SET args=%args% %2
    	SHIFT
    	GOTO :cmdComposer
	) ELSE (
		ECHO larado : composer %args%
		docker run --rm -i -t --mount type=bind,src=%string%,dst=/app composer %args%
	)
	GOTO :end

:: _ Artisan _________________________
:cmdArtisan
	IF DEFINED %1 THEN (
    	SET args=%args% %2
    	SHIFT
    	GOTO :cmdArtisan
	) ELSE (
		ECHO larado : artisan %args%
		docker run --rm -i -t --mount type=bind,src=%string%,dst=/app --network larado-net efynox/laravel-artisan %args%
	)
	GOTO :end

:: _ Serve ___________________________
:cmdServe
	ECHO larado : serve
	ECHO -- Creating network
	docker network create larado-net

	ECHO -- Creating containers
	docker run -i -t -d --name larado-mysql -e "MYSQL_DATABASE=laravel" -e "MYSQL_USER=laravel" -e "MYSQL_PASSWORD=test" -e "MYSQL_RANDOM_ROOT_PASSWORD=yes" --network larado-net --network-alias db -p 3306:3306 mysql 
	docker run --rm -i -t -d --name larado-server -p 8000:8000 --mount type=bind,src=%string%,dst=/app --network larado-net  efynox/laravel-artisan serve --host=0.0.0.0 --port=8000

	ECHO -- Adding cron tasks
	docker exec larado-server bash /root/create-cron.sh
	
	ECHO -- Waiting containers to be ready
	:cmdReady
	(docker logs larado-mysql | find "ready" | find "3306") && GOTO :cmdServe_Migrate
	ECHO | SET /p="."
	GOTO :cmdReady

:cmdServe_Migrate
	ECHO -- Running migrations
	docker run --rm -i -t --mount type=bind,src=%string%,dst=/app --network larado-net efynox/laravel-artisan migrate

	ECHO -- --
	ECHO | SET /p="Host ready at : "
	docker-machine ip
	GOTO :end

:cmdStop
	ECHO larado : stop
	docker stop larado-server
	docker stop larado-mysql
	GOTO :end

:cmdClean
	ECHO larado : clean
	docker rm larado-server
	docker rm larado-mysql
	GOTO :end

:cmdRecreate
	ECHO larado : recreate
	ECHO -- Stopping containers
	docker stop larado-server
	docker stop larado-mysql

	ECHO -- Removing containers
	docker rm larado-server
	docker rm larado-mysql
	GOTO :cmdServe

:: _ Infos ___________________________
:cmdInfos
	ECHO larado : infos
	docker run --rm -i -t --entrypoint=php efynox/laravel-artisan -i
	GOTO :end

:end