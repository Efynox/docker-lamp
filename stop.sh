#!/bin/bash

# Initialize default value
name="EF"

OPTIND=1
while getopts "hn:" opt; do
	case $opt in
		n)
			name=$OPTARG
			;;
		\?) 
			echo "Invalid option: $OPTARG"
			exit 1
			;;
	esac
done

echo "Stopping dockers"
echo "  Name : $name"
echo " "

dockerMysql="${name}_mysql" 
dockerApache="${name}_apache" 

echo "Stopping Apache2-PHP docker..."
docker stop $dockerApache
docker rm $dockerApache
echo " "

echo "Stopping MySQL docker..."
docker stop $dockerMysql
docker rm $dockerMysql
echo " "