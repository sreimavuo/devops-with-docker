# DevOps with Docker - Exercises - Part 2

## Migrating to Docker Compose

### Ex 2.1

docker-compose.yml

``` yaml
version: '3.8'

services:

  simple-compose-test:
    image: devopsdockeruh/simple-web-service
    build: .
    volumes:
      - ./text.log:/usr/src/app/text.log
    container_name: simple-compose-test
```

### Ex 2.2

compose.yaml

``` yaml
version: '3.8'

services:
  webservice:
    image: devopsdockeruh/simple-web-service
    command: ["server"]
    ports:
      - 8080:8080
```

Note - according to the documentation (<https://docs.docker.com/compose/compose-file/03-compose-file/>), `compose.yaml` is the preferred name for the config file (I understand that a lot has happened in the time of this course's existence).

### Ex 2.3*

Let's use the existing Dockerfiles from ex1.12 and ex1.13 for the build:

compose.yaml

``` yaml
services:

  frontend:
    build:
      context: ../../Part1/ex1.12/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8080:8080/tcp"

  backend:
    build:
      context: ../../Part1/ex1.13/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8081:8081/tcp"
```

``` Shell
docker-compose build
docker-compose up
```

Note - Using Compose Specification version of `compose.yaml` (<https://docs.docker.com/compose/compose-file/compose-versioning/>), for example version element is deprecated.

## Docker networking

### Ex 2.4

compose.yaml

``` yaml
services:

  frontend:
    container_name: frontend-server
    build:
      context: ../../Part1/ex1.12/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8080:8080/tcp"

  backend:
    container_name: backend-server
    build:
      context: ../../Part1/ex1.13/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8081:8081/tcp"
    environment:
      - REDIS_HOST=redis-server

  redis:
    container_name: redis-server
    image: redis:latest
    command: ["redis-server"]
    expose:
      - "6379"
```

Commands run:

``` Shell
docker-compose up
```

Note - I understood that the `expose` element allows other containers to see the port that redis is listening to, and does not make it visible to the host machine (<https://docs.docker.com/compose/compose-file/05-services/#expose>). Maybe I need to test further to see if it is necessary, and what it actually does..

### Ex 2.5

Commands run:

``` Shell
docker compose up --scale compute=3
```

## Volumes in action

### Ex 2.6

compose.yaml:

``` yaml
services:

  frontend:
    container_name: frontend-server
    build:
      context: ../../Part1/ex1.12/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8080:8080/tcp"

  backend:
    container_name: backend-server
    build:
      context: ../../Part1/ex1.13/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8081:8081/tcp"
    environment:
      - REDIS_HOST=redis-server
      - POSTGRES_HOST=db-server
      - POSTGRES_PASSWORD=Kissa123

  redis:
    container_name: redis-server
    image: redis:latest
    command: ["redis-server"]
    expose:
      - "6379"

  db:
    container_name: db-server
    image: postgres:latest
    environment:
      - POSTGRES_PASSWORD=Kissa123
    expose:
      - "5432"
    restart: unless-stopped
```

### Ex 2.7

compose.yaml:

``` yaml
services:

  frontend:
    container_name: frontend-server
    build:
      context: ../../Part1/ex1.12/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8080:8080/tcp"

  backend:
    container_name: backend-server
    build:
      context: ../../Part1/ex1.13/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8081:8081/tcp"
    environment:
      - REDIS_HOST=redis-server
      - POSTGRES_HOST=db-server
      - POSTGRES_PASSWORD=Kissa123

  redis:
    container_name: redis-server
    image: redis:latest
    command: ["redis-server"]
    expose:
      - "6379"

  db:
    container_name: db-server
    image: postgres:latest
    volumes:
      - database:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=Kissa123
    expose:
      - "5432"
    restart: unless-stopped

volumes:
  database:
```

### Ex 2.8

compose.yaml:

``` yaml
services:

  frontend:
    container_name: frontend-server
    build:
      context: ../../Part1/ex1.12/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8080:8080/tcp"

  backend:
    container_name: backend-server
    build:
      context: ../../Part1/ex1.13/
      dockerfile: Dockerfile
    ports:
      - "127.0.0.1:8081:8081/tcp"
    environment:
      - REDIS_HOST=redis-server
      - POSTGRES_HOST=db-server
      - POSTGRES_PASSWORD=Kissa123

  redis:
    container_name: redis-server
    image: redis:latest
    command: ["redis-server"]
    expose:
      - "6379"

  db:
    container_name: db-server
    image: postgres:latest
    volumes:
      - database:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=Kissa123
    expose:
      - "5432"
    restart: unless-stopped

  proxy:
    container_name: proxy-server
    image: nginx:latest
    volumes:
      - /Users/zamir/Dropbox/Opiskelu/devops-with-docker/Part2/ex2.8/nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "127.0.0.1:80:80/tcp"

volumes:
  database:
```

nginx.conf:

``` text
events { worker_connections 1024; }

http {
  server {
    listen 80;

    location / {
      proxy_pass http://frontend-server:8080;
    }

    # configure here where requests to http://localhost/api/...
    # are forwarded
    location /api/ {
      proxy_set_header Host $host;
      proxy_pass http://backend-server:8081;
    }
  }
}
```

### Ex 2.9

This was a frustrating exercise as it brought together many things that I knew only partially, but through a standard cycle of new idea => test => failure => krääh => give up => try again, I slowly understood the components and technologies better.

compose.yaml:

``` yaml
services:

  frontend-server:
    container_name: frontend-server
    build:
      context: ./frontend/
      dockerfile: Dockerfile

  backend-server:
    container_name: backend-server
    build:
      context: ./backend/
      dockerfile: Dockerfile
    depends_on:
      - db-server
      - redis-server

  redis-server:
    container_name: redis-server
    image: redis:latest
    command: ["redis-server"]
    expose:
      - "6379"

  db-server:
    container_name: db-server
    image: postgres:latest
    volumes:
      - database:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=Kissa123
    expose:
      - "5432"
    restart: unless-stopped

  proxy-server:
    container_name: proxy-server
    image: nginx:latest
    volumes:
      - ./proxy/nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "127.0.0.1:80:80/tcp"
    depends_on:
      - frontend-server
      - backend-server

volumes:
  database:
```

Frontend Dockerfile:

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

Backend Dockerfile:

``` Dockerfile
FROM ubuntu:latest
ENV PORT=8081 REDIS_HOST=redis-server POSTGRES_HOST=db-server POSTGRES_PASSWORD=Kissa123 
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN apt-get update
RUN apt-get install -y ca-certificates openssl golang-go
RUN go build

CMD ./server
```

nginx.conf:

``` yaml
events { worker_connections 1024; }

http {
  server {
    listen 80;

    location / {
      proxy_pass http://frontend-server:8080;
    }

    # configure here where requests to http://localhost/api/...
    # are forwarded
    location /api/ {
      proxy_set_header Host $host;
      proxy_pass http://backend-server:8081/;
    }

  }
}
```

Key actions to make this work:

- Remove the REACT_APP_BACKEND_URL env variable from frontend Dockerfile so it defaults back to "/api", this causes the buttons for exercise 1.14 and 2.8 to behave the same way (they access the same URL).

- Edit the nginx.conf slightly, so that requests forwarded to backend-server don't go to /api but to / instead.

### Ex 2.10

I removed the published port definitions in the previous exercise already so that only one left was the port 80 for nginx.

Build command:

``` Shell
docker build . -t sami-nmap
```

Dockerfile:

``` Dockerfile
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install --yes nmap
ENTRYPOINT ["nmap"]
```

Run command:

``` Shell
docker run -it --rm --network host sami-nmap localhost
```

Output:

``` Shell
Starting Nmap 7.80 ( https://nmap.org ) at 2023-06-04 14:35 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0000050s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 998 closed ports
PORT    STATE    SERVICE
80/tcp  filtered http
111/tcp open     rpcbind

Nmap done: 1 IP address (1 host up) scanned in 1.25 seconds
```

## Containers in Development

### Ex 2.11

Skipped (I need to try this next, but need to complete the course in time, so utilising the one-skip-per-part-allowed rule).
