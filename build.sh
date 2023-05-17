#!/bin/bash

docker build . -t nginx:job

# Tag the local Docker image
docker tag nginx:job jobjingjo/nginx:job

# Push the Docker image to ACR
docker push jobjingjo/nginx:job
