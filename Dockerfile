# Use an official Maven image as a parent image
FROM maven:3.8.4-openjdk-11

# Set the working directory
WORKDIR /usr/src/app

# Install necessary packages
RUN apt-get update \
    && apt-get install -y \
        firefox-esr \
        wget \
        bzip2 \
        xvfb \
        libdbus-glib-1-2 \
    && rm -rf /var/lib/apt/lists/*

# Install GeckoDriver v0.33.0
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz \
    && tar -xzf geckodriver-v0.33.0-linux64.tar.gz -C /usr/local/bin/ \
    && rm geckodriver-v0.33.0-linux64.tar.gz \
    && chmod +x /usr/local/bin/geckodriver

# Copy the pom.xml file and download dependencies
COPY pom.xml .

# Download dependencies
RUN mvn dependency:resolve

# Copy the rest of the application
COPY . .

# Ensure the target directory is cleaned before running tests
RUN rm -rf target

# Copy the test runner script into the container
COPY run-tests.sh /usr/src/app/

# Make the script executable
RUN chmod +x /usr/src/app/run-tests.sh

# Use the script as the entry point
CMD ["/usr/src/app/run-tests.sh"]
