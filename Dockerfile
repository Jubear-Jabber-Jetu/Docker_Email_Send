# Use an official Maven image as a parent image
FROM maven:3.8.4-openjdk-11

# Set the working directory
WORKDIR /usr/src/app

# Install necessary packages, including ssmtp for sending emails
RUN apt-get update \
    && apt-get install -y \
        firefox-esr \
        wget \
        bzip2 \
        xvfb \
        libdbus-glib-1-2 \
        ssmtp \
    && rm -rf /var/lib/apt/lists/*

# Configure ssmtp to use MailDev
RUN echo "mailhub=localhost:1025\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

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

# Clean and run the tests, but always exit with 0
CMD ["sh", "-c", "mvn clean test || true"]
