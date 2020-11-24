#!/bin/bash
TAG=$1
docker build -t 172.13.28.57/myapp/myapp:$TAG .
docker push 172.13.28.57/myapp/myapp:$TAG