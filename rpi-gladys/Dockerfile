FROM alpine

RUN apk add --no-cache git nodejs mysql python make g++

RUN cd \
 && git clone https://github.com/GladysProject/gladys gladys \
 && cd gladys \
 && npm install \
 && npm install -g grunt-cli \
 && grunt buildProd 

RUN /usr/bin/mysql_install_db --user=mysql \
 && /usr/bin/mysqld_safe --datadir='/var/lib/mysql' \
 && /usr/bin/mysqladmin -u root password 'mypassword' \
 && mysql -u root -p mypassword -e "CREATE DATABASE gladys ;" 

RUN node init.js

COPY .env /root/gladys/.env 

EXPOSE 8080

CMD ["node" ,"app.js"]