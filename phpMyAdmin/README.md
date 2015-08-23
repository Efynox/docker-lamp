# phpMyAdmin docker images

## efynox/phpMyAdmin

To build
```
docker build -t efynox/phpmyadmin .
```

To run it on port 8081
```
docker run -d -p "8081:80" efynox/phpmyadmin HOSTNAME [PORT]
```
replace ```HOSTAME``` by mysql server host name and ```PORT``` by mysql server port