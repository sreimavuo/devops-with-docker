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

