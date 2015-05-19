# MySQL docker images

## Offical MySQL docker image

[Offical documentation](https://registry.hub.docker.com/_/mysql/)

Use the following command to run it
```
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql
```

Use the following command to get a bash for the running docker
```
docker exec -it some-mysql bash
```

## Other MySQL docker image
Based on latest ubuntu docker image

Can be used to have database in a shared folder
