# Use an official Maven image as a parent image
FROM maven:3.8.4-openjdk-11 AS build

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
RUN mvn dependency:resolve

# Copy the rest of the application
COPY . .

# Clean and package the application
RUN mvn clean package

# Second stage: runtime
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy the packaged application from the build stage
COPY --from=build /usr/src/app/target/your-app.jar /usr/src/app/your-app.jar

# Install Firefox and GeckoDriver as needed for runtime (if running tests in this container)
RUN apt-get update \
    && apt-get install -y \
        firefox-esr \
        wget \
        bzip2 \
        xvfb \
        libdbus-glib-1-2 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz \
    && tar -xzf geckodriver-v0.33.0-linux64.tar.gz -C /usr/local/bin/ \
    && rm geckodriver-v0.33.0-linux64.tar.gz \
    && chmod +x /usr/local/bin/geckodriver

# Command to run your application or tests
CMD ["java", "-jar", "/usr/src/app/your-app.jar"]
