FROM ubuntu:latest
ENV REACT_APP_BACKEND_URL="http://localhost:8081"
EXPOSE 8080
WORKDIR /usr/src/app
COPY example-frontend/. .

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash && \
    apt install -y nodejs && \
    npm install && \
    npm update && \
    npm run build && \
    npm install -g serve && \
    useradd -m appuser && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove curl && \
    chown appuser .

USER appuser
CMD ["serve", "-s", "-l", "8080", "build"]

