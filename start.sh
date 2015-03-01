#!/bin/bash

script_path=`dirname $0`

# Usage info
show_help() {
	cat << EOF
Usage:
	-h 		display this help and exit
	-n NAME		set the name
	-p PATH		set the absolute path to web files folder
	-f FOLDER	set the web start folder in the web files folder
	-d DB_PATH  set the db path
	-w PORT 	set the web port
EOF
}

# Initialize default value
name="EF"
web_path=""
web_folder="web"
data_path=""
port="80"

OPTIND=1
while getopts "hn:p:f:d:w:" opt; do
	case $opt in
		h)
			show_help
			exit 0
			;;
		n)
			name=$OPTARG
			;;
		p)
			web_path=$OPTARG
			;;
		f)
			web_folder=$OPTARG
			;;
		d)
			data_path=$OPTARG
			;;
		w)
			port=$OPTARG
			;;
		\?) 
			echo "Invalid option: $OPTARG"
			exit 1
			;;
	esac
done

if [[ $web_path == "" ]] 
	then 
		echo "Error : absolute path to web files folder required, missing -p PATH argument"
		exit 0
fi

if [[ $data_path == "" ]] 
	then 
		data_path="${script_path}/MySQL/data/$name"
fi


echo "Starting dockers"
echo "  Name : $name"
echo "  Web files path : $web_path"
echo "  Web start folder : $web_folder"
echo "  MySQL data folder : $data_path"
echo ""

dockerMysql="${name}_mysql" 
dockerApache="${name}_apache" 

# Start MySQL
echo "Starting MySQL docker..."
docker run --name=$dockerMysql -d -v $data_path:/var/lib/mysql efynox/mysql
echo "MySQL docker started"
echo ""

# Start Apache2 & PHP
echo "Starting Apache2-PHP docker..."
docker run --name=$dockerApache -d -v $web_path:/var/www/app -p $port:80 --link $dockerMysql:db efynox/apache2-php $web_folder
echo "Apache2-PHP docker started on port $port"
echo ""

echo "Waiting database initialization..."
sleep 20
docker logs $dockerMysql
echo ""
