# Use the Maven image with OpenJDK 11 as a base
FROM maven:3.8.4-openjdk-11

# Install necessary packages
RUN apt-get update && \
    apt-get install -y firefox-esr wget bzip2 xvfb libdbus-glib-1-2 && \
    rm -rf /var/lib/apt/lists/*

# Install GeckoDriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz && \
    tar -xzf geckodriver-v0.33.0-linux64.tar.gz -C /usr/local/bin && \
    rm geckodriver-v0.33.0-linux64.tar.gz

# Copy the pom.xml file and download dependencies
COPY pom.xml /app/
WORKDIR /app
RUN mvn dependency:resolve

# Copy the rest of the application code
COPY . /app

# Clean the target directory and prepare the run-tests script
RUN mvn clean

# Copy the script to run tests
COPY run-tests.sh /app/

# Make the script executable
RUN chmod +x /app/run-tests.sh

# Set the entry point to the test script
ENTRYPOINT ["/app/run-tests.sh"]
