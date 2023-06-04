FROM ubuntu:latest
ENV PORT=8081 REDIS_HOST=redis-server POSTGRES_HOST=db-server POSTGRES_PASSWORD=Kissa123 
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN apt-get update
RUN apt-get install -y ca-certificates openssl golang-go
RUN go build

CMD ./server

