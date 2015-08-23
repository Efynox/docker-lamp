# dockers
A list of useful docker

## Apache, PHP
* [efynoxApache2-PHP](Apache2-PHP/README.md)


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
* [efynox/MySQL](MySQL/README.md)


## phpMyAdmin
* [efynox/MySQL](phpMyAdmin/README.md)

## OpenVPN
* [jpetazzo/dockvp git repository](https://github.com/jpetazzo/dockvpn)