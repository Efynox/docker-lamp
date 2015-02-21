
FROM ubuntu:latest
MAINTAINER Efynox <efynox@live.fr>

ENV MYSQL_USERNAME root
ENV MYSQL_PASSWORD password


# Get some security updates
#RUN apt-get update
#RUN apt-get -y upgrade
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# Install MySQL
RUN apt-get install -y mysql-server

ADD ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

VOLUME /var/lib/mysql

# Add our config files
#ADD conf/nginx.conf /usr/local/nginx/conf/nginx.conf 
#ADD conf/php.ini /etc/php5/fpm/php.ini

EXPOSE 3306

CMD ["./root/run.sh"]