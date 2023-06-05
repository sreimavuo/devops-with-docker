FROM ubuntu:latest
ENV PORT=8081 REQUEST_ORIGIN=*
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN apt-get update && \
    apt-get install -y ca-certificates openssl golang-go && \
    go build && \
    adduser --disabled-password --gecos "appuser" appuser && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove golang-go && \
    chown appuser .

USER appuser
CMD ./server

