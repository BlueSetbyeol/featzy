FROM node:20-alpine AS builder

ARG GITHUB_REPO
ARG GITHUB_TOKEN
ARG VITE_API_URL=/api

RUN apk add --no-cache git && \
    git clone --depth 1 --sparse \
        https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git /tmp/repo && \
    cd /tmp/repo && git sparse-checkout set client && \
    mkdir -p /app && cp -r client/. /app/ && \
    rm -rf /tmp/repo

WORKDIR /app

RUN npm ci && VITE_API_URL=${VITE_API_URL} npx vite build


FROM httpd:alpine

COPY --from=builder /app/dist /usr/local/apache2/htdocs
COPY apache.conf /usr/local/apache2/conf/extra/app.conf

RUN echo "Include conf/extra/app.conf" >> /usr/local/apache2/conf/httpd.conf && \
    sed -i \
        -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
        -e 's/#LoadModule proxy_module/LoadModule proxy_module/' \
        -e 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/' \
        /usr/local/apache2/conf/httpd.conf
