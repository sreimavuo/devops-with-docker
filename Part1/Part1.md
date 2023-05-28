# DevOps with Docker - Exercises - Part 1

## Definitions and basic concepts

### Ex 1.1

``` zsh
➜  Part1 git:(master) ✗ docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
cd333c3093d7   nginx     "/docker-entrypoint.…"   48 seconds ago   Exited (0) 34 seconds ago             recursing_swartz
59bfc2f40be2   nginx     "/docker-entrypoint.…"   50 seconds ago   Exited (0) 34 seconds ago             gracious_bell
13e3767e657a   nginx     "/docker-entrypoint.…"   51 seconds ago   Up 50 seconds               80/tcp    angry_meitner
```

### Ex 1.2

``` zsh
➜  Part1 git:(master) ✗ docker ps -a      
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

```

``` zsh
➜  Part1 git:(master) ✗ docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE

```

## Running and stopping containers

### Ex 1.3

``` zsh
➜  Part1 git:(master) ✗ docker run -d --rm -it --name mystery devopsdockeruh/simple-web-service:ubuntu
➜  Part1 git:(master) ✗ docker exec -it mystery bash
```

``` bash
root@511356b96a22:/usr/src/app# tail -f ./text.log
```

The secret message is:
>Secret message is: 'You can find the source code here: <https://github.com/docker-hy>'

### Ex 1.4

``` zsh
➜  Part1 git:(master) ✗ docker run -d --rm -it --name crawler ubuntu sh -c 'while true; do echo "Input website:"; read website; echo "Searching.."; sleep 1; curl http://$website; done' 
➜  Part1 git:(master) ✗ docker exec -it crawler bash
```

``` bash
root@32c7723b2338:/# apt-get update
root@32c7723b2338:/# apt-get install curl
root@32c7723b2338:/# exit
```

``` zsh
➜  Part1 git:(master) ✗ docker attach crawler
```

## In-depth dive to images

### Ex 1.5

``` Shell
➜  Part1 git:(master) ✗ docker pull devopsdockeruh/simple-web-service:ubuntu
...

➜  Part1 git:(master) ✗ docker pull devopsdockeruh/simple-web-service:alpine
...

➜  Part1 git:(master) ✗ docker images devopsdockeruh/simple-web-service
REPOSITORY                          TAG       IMAGE ID       CREATED       SIZE
devopsdockeruh/simple-web-service   ubuntu    4e3362e907d5   2 years ago   83MB
devopsdockeruh/simple-web-service   alpine    fd312adc88e0   2 years ago   15.7MB
```

Alpine-version is significantly smaller.

``` Shell
➜  Part1 git:(master) ✗ docker run -d --rm -it --name mystery devopsdockeruh/simple-web-service:alpine
...

➜  Part1 git:(master) ✗ docker exec -it mystery sh
...
```

``` Shell
/usr/src/app # tail -f ./text.log
...
```

The secret message is the same as in the ubuntu-version of the image.

### Ex 1.6

``` Shell
➜  Part1 git:(master) ✗ docker run -it devopsdockeruh/pull_exercise
````

Docker Hubista ei löytynyt oikeen mitään hyödyllistä imageen liittyen, mutta ohjeistuksesta käsitin että jos Docker Hubista ei löydy tietoa niin sitten sitä todennäköisesti löytyy organisaation Github-reposta (mikä selvisi aiemman tehtävän salaisesta viestistä).

Repoa selailemalla löytyi mahdollinen vastaus (<https://github.com/docker-hy/docs-exercise>) joka toimikin, salasana oli `basics` ja viesti `"This is the secret message"`.

### Ex 1.7

Dockerfile:

``` Dockerfile
# Start from the Ubuntu image
FROM ubuntu:20.04

# Use /usr/src/app as our workdir. The following instructions will be executed in this location.
WORKDIR /usr/src/app

# Copy the curler.sh file to the workdir (/usr/src/app/).
COPY curler.sh .

# Ensure our script has execute rights
RUN chmod +x ./curler.sh

# Install curl
RUN apt-get update
RUN apt-get install --yes curl

# When running Docker run the command will be ./curler.sh
CMD ./curler.sh
```

### Ex 1.8

Dockerfile:

``` Dockerfile
FROM devopsdockeruh/simple-web-service:alpine
CMD server
```

``` Shell
➜  ex1.8 git:(master) ✗ docker run web-server
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
[GIN-debug] [WARNING] Creating an Engine instance with the Logger and Recovery middleware already attached.

[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /*path                    --> server.Start.func1 (3 handlers)
[GIN-debug] Listening and serving HTTP on :8080
```

## Interacting with the container via volumes and ports

### Ex 1.9

``` Shell
➜  ex1.9 git:(master) ✗ touch text.log
docker run -v "$(pwd)/text.log:/usr/src/app/text.log" devopsdockeruh/simple-web-service
```

### Ex 1.10

Output from browser:

``` Text
message:   "You connected to the following path: /"
path:      "/"
```

Commands:

``` Shell
docker run -p 127.0.0.1:8080:8080 devopsdockeruh/simple-web-service server
```

## Utilizing tools from the Registry

### Ex 1.11



### Ex 1.12*

### Ex 1.13*

### Ex 1.14*

### Ex 1.15

### Ex 1.16
