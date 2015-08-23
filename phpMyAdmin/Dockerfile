FROM debian:latest
MAINTAINER Efynox <efynox@live.fr>

ENV PHPMYADMIN_VERSION 4.4.11

ENV MAX_UPLOAD "50M"

# Get some security updates
RUN apt-get update

# Install Apache2 and php5
RUN apt-get -y install apache2; apt-get -y install php5 php5-gd php5-mysql php5-mcrypt

# Remove default site
RUN a2dissite 000-default

# Installation de phpMyAdmin
RUN apt-get -y install wget bzip2; wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2; tar -xvjf /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2 -C / ; rm /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2 ; mv /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
ADD ./config.inc.php /var/www/phpmyadmin/config.inc.php

# Add phpMyAdmin to Apache2
ADD ./phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
RUN a2ensite phpmyadmin

# Enable Mod Rewrite
RUN a2enmod rewrite

# Copy PHP config file
#ADD ./conf/php.ini /etc/php5/apache2/php.ini

# Active modes php
RUN php5enmod mcrypt

#
EXPOSE 80

# Copy run script
ADD ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

ENTRYPOINT ["./root/run.sh"]
