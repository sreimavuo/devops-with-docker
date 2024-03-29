# DevOps with Docker - Exercises - Part 3

## Deployment Pipelines

### Ex 3.1

Link to the repository: <https://github.com/sreimavuo/express-app>.

### Ex 3.2

I kept using [Fly.io](https://fly.io/) as the cloud provider and found simple enough instructions on how to do it from [here](https://fly.io/docs/app-guides/continuous-deployment-with-github-actions/) and[here](https://medium.com/geekculture/deploy-docker-images-on-fly-io-free-tier-afbfb1d390b1).

The deployment is integrated in the ex3.1 GHA workflow (see link to repo above), and I realise there are several ways to arrange the pipeline. I opted for deploying to Fly.io from DockerHub, running the jobs in sequence instead of branching to two parallel tasks.

### Ex 3.3

builder.sh:

``` Shell
#!/bin/sh

#
# Prep
#

# This is what we have
echo " "
echo GitHub repository to pull from: $1
echo DockerHub repository to push to: $2
echo " "

GITHUB_REPO=$1
DOCKER_REPO=$2

# If credential env variables are not set, exit with error
[[ ! -n "${DOCKER_PASS}" ]] && echo "DOCKER_PASS is not set, exiting.." && exit 1
[[ ! -n "${DOCKER_USER}" ]] && echo "DOCKER_USER is not set, exiting.." && exit 1

# If there are no command-line arguments, exit with error
[[ ! -n "${GITHUB_REPO}" ]] && echo "GITHUB_REPO is not set, exiting.." && exit 1
[[ ! -n "${DOCKER_REPO}" ]] && echo "DOCKER_REPO is not set, exiting.." && exit 1

# If local copy of repo already exists, exit with error
REPONAME="`echo $1 | cut -d"/" -f2`"
[ -d $REPONAME ] && echo "local repo dir: $REPONAME already exists, abort mission" && exit 1

#
# Run
#

# Pull the repo from GitHub
echo "RUN STAGE 1: PULL REPO FROM GITHUB"
git clone git@github.com:$GITHUB_REPO.git

# Build the image using Dockerfile
echo "RUN STAGE 2: BUILD IMAGE"
cd $REPONAME
echo Current directory is: `pwd`
docker build . -t $DOCKER_REPO

# Authenticate to DockerHub
echo "RUN STAGE 3: PUSH IMAGE TO DOCKERHUB"
docker login --username $DOCKER_USER --password $DOCKER_PASS

# Push the image to DockerHub
docker push $DOCKER_REPO:latest

echo "DONE"
```

### Ex 3.4

The shell script is the same as in ex3.3 above, but with one small adjustment, using `git clone https://github.com/...` instead of `git clone git@github.com:...` as it doesn't require setting up GitHub credentials inside the build container, and we just want to pull the public repo for building, not for pushing changes.

Dockerfile:

``` Dockerfile
FROM docker:latest
WORKDIR /usr/src/app
COPY ./builder.sh .
RUN apk add git

ENTRYPOINT ["./builder.sh"]
```

Command:

`docker run -e DOCKER_USER=sreimavuo -e DOCKER_PASS=password_here -v /var/run/docker.sock:/var/run/docker.sock builder sreimavuo/express-app sreimavuo/express-app`

## Using a Non-root User

### Ex 3.5*

frontend Dockerfile:

``` Dockerfile
FROM ubuntu:latest
ENV REACT_APP_BACKEND_URL="http://localhost:8081"
EXPOSE 8080
WORKDIR /usr/src/app
COPY example-frontend/. .

RUN apt-get update
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN apt install -y nodejs

RUN npm install
RUN npm update
RUN npm run build
RUN npm install -g serve

RUN useradd -m appuser
RUN chown appuser .

USER appuser

CMD ["serve", "-s", "-l", "8080", "build"]
```

backend Dockerfile:

``` Dockerfile
FROM ubuntu:latest
ENV PORT=8081 REQUEST_ORIGIN=*
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN apt-get update
RUN apt-get install -y ca-certificates openssl golang-go
RUN go build

RUN adduser --disabled-password --gecos "appuser" appuser
RUN chown appuser .
USER appuser

CMD ./server
```

## Optimizing the Image Size

### Ex 3.6

Starting position (Ubuntu generic images):

``` Shell
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
frontend        latest    bdeadc034d0b   19 minutes ago       828MB
backend         latest    ac2f911cb58c   18 minutes ago       991MB
```

After combining RUN layers and removing unneeded things (apt-get cache, curl):

``` Shell
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
frontend-ex36   latest    250ddf26550b   About a minute ago   654MB
backend-ex36    latest    5403e9a48f54   6 minutes ago        227MB
```

frontend savings were not so great, I didn't touch the whole nodejs thing, as I am not familiar with it (not yet anyway), so wasn't sure what could be removed or how. backend however shrank quite a bit as I uninstalled Golang once the app was compiled.

### Ex 3.7

``` Shell
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
frontend-ex37   latest    47a9adcb4135   18 seconds ago      567MB
backend-ex37    latest    7cb830f90a3c   33 minutes ago      482MB
```

Using `node:16-alpine3.18` and `golang:1.20.4-alpine3.18` for these.

### Ex 3.8

``` Shell
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
frontend-ex38   latest    f1fa3f678d5e   36 seconds ago      128MB
```

Dockerfile:

``` Dockerfile
FROM node:16-alpine3.18 as build-stage
WORKDIR /usr/src/app
COPY example-frontend/. .

RUN npm install && \
    npm update && \
    npm run build

# The run stage
FROM node:16-alpine3.18
ENV REACT_APP_BACKEND_URL="http://localhost:8081"
EXPOSE 8080
WORKDIR /usr/src/app

COPY --from=build-stage /usr/src/app/build /usr/src/app/build

RUN npm install -g serve && \
    adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .

USER appuser
CMD ["serve", "-s", "-l", "8080", "build"]
```

### Ex 3.9

``` Shell
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
backend-ex39    latest    2b3277ffaa7c   36 seconds ago       25.5MB
```

Dockerfile:

``` Dockerfile
FROM golang:1.20.4-alpine3.18 as build-stage
WORKDIR /usr/src/app
COPY example-backend/. .
RUN go build

# The run stage
FROM alpine:3.18
WORKDIR /usr/src/app
ENV PORT=8081 REQUEST_ORIGIN=*
EXPOSE 8081
COPY --from=build-stage /usr/src/app/server /usr/src/app/server

RUN adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .
USER appuser
CMD ./server
```

### Ex 3.10

I used the spring-example-project from ex1.11.

``` Shell
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
spring-new   latest    f9689d2cc879   About a minute ago   121MB
spring-old   latest    e873416cc7ce   10 minutes ago       606MB
```

Dockerfile before:

``` Dockerfile
FROM openjdk:8
EXPOSE 8080
WORKDIR /usr/src/app
COPY spring-example-project/. .
RUN ./mvnw package
CMD ["java", "-jar", "./target/docker-example-1.1.3.jar"]
```

Dockerfile after:

``` Dockerfile
FROM openjdk:8-alpine3.9 as build-env
WORKDIR /usr/src/app
COPY spring-example-project/. .
RUN ./mvnw package

FROM openjdk:8-alpine3.9
WORKDIR /usr/src/app
EXPOSE 8080
COPY --from=build-env /usr/src/app/target /usr/src/app/target
RUN adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .
USER appuser
CMD ["java", "-jar", "./target/docker-example-1.1.3.jar"]

```

## Multi-host Environments

### Ex 3.11

Skipped for now, just to get the course completed before deadline. Will get back to this later!
