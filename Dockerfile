FROM debian:stable-slim
WORKDIR /app
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip && rm -rf /var/lib/apt/lists/*
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
COPY . /app
RUN flutter pub get
ARG API_BASE_URL
ENV API_BASE_URL=${API_BASE_URL}
RUN if [ -n "$API_BASE_URL" ]; then \
      flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}; \
    else \
      flutter build web --release; \
    fi
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
EXPOSE 80
