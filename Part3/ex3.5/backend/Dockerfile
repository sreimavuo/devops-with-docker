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

