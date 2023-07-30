# Start with a base Ubuntu image
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y git wget curl unzip libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set Flutter and Dart path
ENV PATH $PATH:/usr/local/flutter/bin
ENV PATH $PATH:`/usr/local/flutter/bin/flutter doctor --android-licenses`

# Enable Flutter web
RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web

# Copy the app
WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build the app
RUN flutter build apk

# Use NGINX as a lightweight web server to serve your Flutter app
FROM nginx:alpine

# Copy the built Flutter app from the previous stage
COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk /usr/share/nginx/html

# Expose port 80 for the NGINX server
EXPOSE 80