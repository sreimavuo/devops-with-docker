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

