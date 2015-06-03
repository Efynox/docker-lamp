#!/bin/bash

# Defaults values
hostname="localhost"
port=3306


if [[ $1 != "" ]]
	then
    hostname=$1
fi


if [[ $2 != "" ]]
	then
    port=$2
fi

# Set the host
sed -i "s|SERVER_HOST|$hostname|g" /var/www/phpmyadmin/config.inc.php

# Set the port
sed -i "s|SERVER_PORT|$port|g" /var/www/phpmyadmin/config.inc.php

echo "phpMyAdmin started at for server "$hostname":"$port

apache2ctl -D FOREGROUND
