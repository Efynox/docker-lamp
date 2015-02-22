
FROM ubuntu:latest
MAINTAINER Efynox <efynox@live.fr>

ENV PHPMYADMIN_VERSION 4.3.9
ENV PHPMYADMIN_SECRET blowfish_secret
ENV PHPMYADMIN_USERNAME pma
ENV PHPMYADMIN_PASSWORD password

ENV MAX_UPLOAD "50M"

# Get some security updates
#RUN apt-get update
#RUN apt-get -y upgrade

# Install Apache2 and php5
RUN apt-get -y install apache2
RUN apt-get -y install php5 php5-gd php5-mysql


# Installation de phpMyAdmin
RUN apt-get -y install wget
RUN wget http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2
RUN tar -xvjf /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2 -C /
RUN rm /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.bz2
RUN mv /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin

#
VOLUME /var/www/app

RUN a2dissite 000-default

ADD ./sites/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf
RUN a2ensite phpmyadmin

ADD ./sites/app.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app

EXPOSE 80

ADD ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

CMD ["./root/run.sh"]