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
```

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

``` Shell
➜  ex1.11 git:(master) ✗ git clone git@github.com:docker-hy/material-applications.git
➜  ex1.11 git:(master) ✗ cd material-applications/spring-example-project/
```

Dockerfile:

``` Dockerfile
FROM openjdk:8
EXPOSE 8080
WORKDIR /usr/src/app
COPY . . 
RUN ./mvnw package
CMD ["java", "-jar", "./target/docker-example-1.1.3.jar"]
```

``` Shell
docker build . -t spring-server
docker run -p 127.0.0.1:8080:8080 --rm spring-server
```

Note - openjdk-container had over 400 pages of different tags and there was a notice it is deprecated. I ended up searching the Discord channel for the course and found a hint to use tag "8". So, in a sense very lifelike exercise, but maybe there could be a bit of guidance how to best filter the results when browsing the tags in Docker Hub?

### Ex 1.12*

Dockerfile:

``` Dockerfile
FROM ubuntu:latest
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

CMD ["serve", "-s", "-l", "8080", "build"]
```

``` Shell
docker build . -t frontti
docker run -p 127.0.0.1:8080:8080 --rm frontti
```

### Ex 1.13*

Dockerfile:

``` Dockerfile
FROM ubuntu:latest
ENV PORT=8081
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN apt-get update
RUN apt-get install -y ca-certificates openssl golang-go
RUN go build

CMD ./server
```

``` Shell
docker build . -t bakki
docker run -p 127.0.0.1:8081:8081 --rm bakki
```

Got a pong in response.

### Ex 1.14*

Frontend Dockerfile:

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

CMD ["serve", "-s", "-l", "8080", "build"]
```

Backend Dockerfile:

``` Dockerfile
FROM ubuntu:latest
ENV PORT=8081 REQUEST_ORIGIN=*
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN apt-get update
RUN apt-get install -y ca-certificates openssl golang-go
RUN go build

CMD ./server
```

Commands to run to get the show on the road:

``` Shell
docker run -p 127.0.0.1:8080:8080 --rm frontti
docker run -p 127.0.0.1:8081:8081 --rm bakki
```

### Ex 1.15

Skipped

### Ex 1.16

I created account to Fly.io (<https://fly.io/app/sign-up>), verified email account and activated 2FA. And added credit card details, luckily it doesn't look like small scale testing would cost anything (<https://fly.io/docs/about/pricing/>).

As I run macos, I installed Fly.io command-line tools with:

``` Shell
brew install flyctl
```

Signed in (redirects to browser for login):

``` Shell
flyctl auth login
```

I selected the exercise 1.11 Java Spring example app as it is simple and doesn't have dependencies so I can concentrate on learning and testing the deployment process.

Fly.io has separate instructions for deploying from local Docker installations (<https://fly.io/docs/languages-and-frameworks/dockerfile/>).

``` Shell
➜  ex1.16 git:(master) ✗ fly launch
Creating app in /Users/zamir/Dropbox/Opiskelu/devops-with-docker/Part1/ex1.16
Scanning source code
Detected a Dockerfile app
? Choose an app name (leave blank to generate one): spring-fly
automatically selected personal organization: Sami
Some regions require a paid plan (fra, maa).
See https://fly.io/plans to set up a plan.

? Choose a region for deployment: Stockholm, Sweden (arn)
App will use 'arn' region as primary

Created app 'spring-fly' in organization 'personal'
Admin URL: https://fly.io/apps/spring-fly
Hostname: spring-fly.fly.dev
? Would you like to set up a Postgresql database now? No
? Would you like to set up an Upstash Redis database now? No
? Create .dockerignore from 1 .gitignore files? No
Wrote config file fly.toml
? Would you like to deploy now? Yes
Validating /Users/zamir/Dropbox/Opiskelu/devops-with-docker/Part1/ex1.16/fly.toml
Platform: machines
✓ Configuration is valid
==> Building image
Remote builder fly-builder-little-flower-3809 ready
==> Creating build context
--> Creating build context done
==> Building image with Docker
--> docker host: 20.10.12 linux x86_64
Sending build context to Docker daemon  8.253kB
[+] Building 23.2s (8/8) FINISHED                                                                                                                                    
 => [internal] load remote build context                                                                                                                        0.0s
 => copy /context /                                                                                                                                             0.1s
 => [internal] load metadata for docker.io/library/openjdk:8                                                                                                    1.0s
 => [1/4] FROM docker.io/library/openjdk:8@sha256:86e863cc57215cfb181bd319736d0baf625fe8f150577f9eb58bd937f5452cb8                                              6.9s
 => => resolve docker.io/library/openjdk:8@sha256:86e863cc57215cfb181bd319736d0baf625fe8f150577f9eb58bd937f5452cb8                                              0.0s
 => => sha256:d85151f15b6683b98f21c3827ac545188b1849efb14a1049710ebc4692de3dd5 5.42MB / 5.42MB                                                                  0.4s
 => => sha256:52a8c426d30b691c4f7e8c4b438901ddeb82ff80d4540d5bbd49986376d85cc9 210B / 210B                                                                      0.4s
 => => sha256:8754a66e005039a091c5ad0319f055be393c7123717b1f6fee8647c338ff3ceb 105.92MB / 105.92MB                                                              2.1s
 => => sha256:9daef329d35093868ef75ac8b7c6eb407fa53abbcb3a264c218c2ec7bca716e6 54.58MB / 54.58MB                                                                1.1s
 => => sha256:3af2ac94130765b73fc8f1b42ffc04f77996ed8210c297fcfa28ca880ff0a217 1.79kB / 1.79kB                                                                  0.0s
 => => sha256:b273004037cc3af245d8e08cfbfa672b93ee7dcb289736c82d0b58936fb71702 7.81kB / 7.81kB                                                                  0.0s
 => => sha256:001c52e26ad57e3b25b439ee0052f6692e5c0f2d5d982a00a8819ace5e521452 55.00MB / 55.00MB                                                                1.0s
 => => sha256:d9d4b9b6e964657da49910b495173d6c4f0d9bc47b3b44273cf82fd32723d165 5.16MB / 5.16MB                                                                  0.4s
 => => sha256:2068746827ec1b043b571e4788693eab7e9b2a95301176512791f8c317a2816a 10.88MB / 10.88MB                                                                0.4s
 => => sha256:86e863cc57215cfb181bd319736d0baf625fe8f150577f9eb58bd937f5452cb8 1.04kB / 1.04kB                                                                  0.0s
 => => extracting sha256:001c52e26ad57e3b25b439ee0052f6692e5c0f2d5d982a00a8819ace5e521452                                                                       1.7s
 => => extracting sha256:d9d4b9b6e964657da49910b495173d6c4f0d9bc47b3b44273cf82fd32723d165                                                                       0.2s
 => => extracting sha256:2068746827ec1b043b571e4788693eab7e9b2a95301176512791f8c317a2816a                                                                       0.2s
 => => extracting sha256:9daef329d35093868ef75ac8b7c6eb407fa53abbcb3a264c218c2ec7bca716e6                                                                       1.7s
 => => extracting sha256:d85151f15b6683b98f21c3827ac545188b1849efb14a1049710ebc4692de3dd5                                                                       0.2s
 => => extracting sha256:52a8c426d30b691c4f7e8c4b438901ddeb82ff80d4540d5bbd49986376d85cc9                                                                       0.0s
 => => extracting sha256:8754a66e005039a091c5ad0319f055be393c7123717b1f6fee8647c338ff3ceb                                                                       1.3s
 => [2/4] WORKDIR /usr/src/app                                                                                                                                  0.1s
 => [3/4] COPY spring-example-project/. .                                                                                                                       0.0s
 => [4/4] RUN ./mvnw package                                                                                                                                   14.6s
 => exporting to image                                                                                                                                          0.6s 
 => => exporting layers                                                                                                                                         0.6s 
 => => writing image sha256:2464822a08860b46567dd84f4f8a1c97e07c6ebd77e0e05c940accfab473ac97                                                                    0.0s 
 => => naming to registry.fly.io/spring-fly:deployment-01H1PCSA5RR60SSE3P2ZTGJ0ZN                                                                               0.0s 
--> Building image done                                                                                                                                              
==> Pushing image to fly                                                                                                                                             
The push refers to repository [registry.fly.io/spring-fly]
358f286059dd: Pushed 
7a5196542294: Pushed 
82b43668a934: Pushed 
6b5aaff44254: Pushed 
53a0b163e995: Pushed 
b626401ef603: Pushed 
9b55156abf26: Pushed 
293d5db30c9f: Pushed 
03127cdb479b: Pushed 
9c742cd6c7a5: Pushed 
deployment-01H1PCSA5RR60SSE3P2ZTGJ0ZN: digest: sha256:c763740af3dae51795adfdc2ea6c52ae45f9b3b05f67c467cae6f04ab86baa67 size: 2422
--> Pushing image done
image: registry.fly.io/spring-fly:deployment-01H1PCSA5RR60SSE3P2ZTGJ0ZN
image size: 611 MB

Watch your app at https://fly.io/apps/spring-fly/monitoring

Provisioning ips for spring-fly
  Dedicated ipv6: 2a09:8280:1::24:2241
  Shared ipv4: 66.241.125.188
  Add a dedicated ipv4 with: fly ips allocate-v4
This deployment will:
 * create 2 "app" machines

No machines in group app, launching a new machine
  Machine 148edd72c73768 [app] update finished: success
Creating a second machine to increase service availability
  Machine 5683dd73f796e8 [app] update finished: success
Finished launching new machines

NOTE: The machines for [app] have services with 'auto_stop_machines = true' that will be stopped when idling

Updating existing machines in 'spring-fly' with rolling strategy
  Finished deploying

Visit your newly deployed app at https://spring-fly.fly.dev/
```

And there it is at <https://spring-fly.fly.dev/>, success!
