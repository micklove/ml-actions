## Github Actions
Until there's one available, create a local "github actions"-like image, to test with.

## Create, with make
Run the `rebuild` make task, to:
+ stop any existing image
+ build the image
+ bring up as a service


    make rebuild



## Docker compose 

### docker compose build
    docker-compose build

### up / down
Run with -d for detached mode

    docker-compose up -d

Stop, without losing container

    docker-compose stop
    
Stop, container, network, etc...

    docker-compose down

### run - and get shell using the service name, with docker-compose
    docker-compose exec ml-actions-ubuntu bash


### Run, in current folder
Create a temporary container, deleted on exit, at the current folder

    docker run --rm -v ${PWD}:/target -it ml-actions/ubuntu bash

#### Run, allowing access to Docker service on the host (allows dind (docker in docker))
    docker run --rm -v ${PWD}:/target  -v /var/run/docker.sock:/var/run/docker.sock -it ml-actions/ubuntu bash


#### References
https://stackoverflow.com/a/39150040/178808
https://docs.docker.com/compose/compose-file/#dockerfile
