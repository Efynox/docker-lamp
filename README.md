# dockers
A list of useful docker

## Apache, PHP
* [efynox/Apache2-PHP](Apache2-PHP/)


## MySQL 

### Offical MySQL docker image

[Offical documentation](https://registry.hub.docker.com/_/mysql/)

Use the following command to run it
```
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql
```

Use the following command to get a bash for the running docker
```
docker exec -it some-mysql bash
```

### Others
* [efynox/MySQL](MySQL/)


## phpMyAdmin
### Official
[phpmyadmin/docker](https://github.com/phpmyadmin/docker)

### Others
* [efynox/phpMyAdmin](phpMyAdmin/)

## OpenVPN
* [jpetazzo/dockvp git repository](https://github.com/jpetazzo/dockvpn)
