FROM debian:latest
MAINTAINER Efynox <efynox@live.fr>

ENV PHPMYADMIN_VERSION 4.4.11

ENV MAX_UPLOAD "50M"

# Install apache2, php5
RUN apt-get update &&  apt-get -y install apache2; apt-get -y install php5 php5-gd php5-mysql php5-mcrypt

# Installation de phpMyAdmin
RUN apt-get -y install wget bzip2 ; wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2; tar -xvjf /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2 -C / ; rm /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2 ; mv /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
ADD ./config.inc.php /var/www/phpmyadmin/config.inc.php

# Remove default site, Add phpMyAdmin to Apache2, Enable Mod Rewrite, Enables php modes
ADD ./phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
RUN a2dissite 000-default ; a2ensite phpmyadmin ; a2enmod rewrite ; php5enmod mcrypt

#
EXPOSE 80

# Copy run script
ADD ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

ENTRYPOINT ["./root/run.sh"]
