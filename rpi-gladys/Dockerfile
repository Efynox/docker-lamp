FROM alpine

RUN apk add --no-cache git nodejs mysql mysql-client python make g++

RUN cd \
 && git clone https://github.com/GladysProject/gladys gladys \
 && cd gladys \
 && npm install \
 && npm install -g grunt-cli \
 && grunt buildProd 
 
RUN /usr/bin/mysql_install_db --user=mysql \
RUN /usr/bin/mysqld_safe --datadir='/var/lib/mysql' &
RUN /usr/bin/mysqladmin -u root password 'mypassword' 
RUN mysql --user=root --password=mypassword -e "CREATE DATABASE gladys ;" 

COPY .env /root/gladys/.env 

RUN node init.js

EXPOSE 8080

CMD ["node" ,"app.js"]