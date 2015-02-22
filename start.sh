#!/bin/bash

path=`pwd`'/MySQL/data'

# Start MySQL
echo "Starting MySQL docker..."
echo "	Data:" $path
echo "	Container ID:"
docker run --name=ef_mysql -d -v $path:/var/lib/mysql efynox/mysql
echo "	MySQL docker started on port 3306"

docker logs ef_mysql
echo " "

# Start Apache2 & PHP
echo "Starting Apache2-PHP docker..."
echo "	Files:" $1
echo "	Container ID:"
docker run --name=ef_apache -d -v $1:/var/www/app -p 80:80 --link ef_mysql:db efynox/apache2-php
echo "	Apache2-PHP docker started on port 80"


