FROM debian:stable-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

COPY . /app

RUN flutter pub get

RUN flutter build web --release

FROM nginx:alpine

COPY --from=0 /app/build/web /usr/share/nginx/html

EXPOSE 80
GitHub - flutter/flutter: Flutter makes it easy and fast to build beautiful apps for mobile and beyond
Flutter makes it easy and fast to build beautiful apps for mobile and beyond - flutter/flutter
 
