
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

# Add run script
ADD ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Define 
VOLUME /var/lib/mysql

# Define port
EXPOSE 3306

# Define the command to launch
CMD ["./root/run.sh"]