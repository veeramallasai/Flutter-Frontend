FROM debian:stable-slim
WORKDIR /app
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip && rm -rf /var/lib/apt/lists/*
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
COPY . /app
RUN flutter pub get
ARG API_BASE_URL
ARG GOOGLE_WEB_CLIENT_ID
ARG APPLE_SERVICE_ID
ARG APPLE_REDIRECT_URI
ENV API_BASE_URL=${API_BASE_URL}
RUN flutter build web --release \
      --dart-define=API_BASE_URL=${API_BASE_URL} \
      --dart-define=GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID} \
      --dart-define=APPLE_SERVICE_ID=${APPLE_SERVICE_ID} \
      --dart-define=APPLE_REDIRECT_URI=${APPLE_REDIRECT_URI}
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
