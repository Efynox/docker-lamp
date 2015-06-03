# phpMyAdmin docker images

## efynox/phpMyAdmin

To build
```
sudo docker build -t efynox/phpmyadmin .
```

To run it on port 8081
```
sudo docker run -d -p "8081:80" efynox/phpmyadmin HOSTNAME [PORT]
```
