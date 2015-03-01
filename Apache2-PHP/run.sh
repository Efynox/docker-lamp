#!/bin/bash

# Set the start folder
if [[ $1 != "" ]]
	then
		sed -i "s|WEB|$1|g" /etc/apache2/sites-enabled/app.conf
fi

apache2ctl -D FOREGROUND