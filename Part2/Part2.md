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

compose.yaml:

``` yaml

```

### Ex 2.10

compose.yaml:

``` yaml

```

## Containers in Development

### Ex 2.11

Skipped (I need to try this next, but need to complete the course in time, so utilising the one-skip-per-part-allowed rule).
