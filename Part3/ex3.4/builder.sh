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
git clone https://github.com/$GITHUB_REPO.git

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

