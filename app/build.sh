#!/bin/bash

docker build . -t dotnet6:webapi

# Tag the local Docker image
docker tag dotnet6:webapi jobjingjo/dotnet6:webapi

# Push the Docker image to ACR
docker push jobjingjo/dotnet6:webapi
