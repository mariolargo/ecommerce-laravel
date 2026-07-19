FROM nginx:alpine

RUN apk update && apk add --no-cache openssl

RUN mkdir -p /etc/ssl/certs/ && mkdir -p /etc/ssl/private/

RUN if [ ! -f /etc/ssl/certs/self-signed.crt ]; then \
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/self-signed.key \
      -out /etc/ssl/certs/self-signed.crt \
      -subj '/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost'; \
    fi

WORKDIR /var/www/html