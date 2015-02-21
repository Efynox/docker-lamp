#!/bin/bash

echo "Stopping Apache2-PHP docker..."
docker stop ef_apache
docker rm ef_apache

echo " "

echo "Stopping MySQL docker..."
docker stop ef_mysql
docker rm ef_mysql