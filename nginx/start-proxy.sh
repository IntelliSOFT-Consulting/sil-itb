#!/bin/sh
set -e
apk add --no-cache openssl >/dev/null
DOMAIN=itbsil.helina.africa
LIVE_DIR="/etc/letsencrypt/live/$DOMAIN"
if [ ! -f "$LIVE_DIR/fullchain.pem" ] || [ ! -f "$LIVE_DIR/privkey.pem" ]; then
  echo "nginx: creating temporary self-signed certificate"
  mkdir -p "$LIVE_DIR"
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout "$LIVE_DIR/privkey.pem" \
    -out "$LIVE_DIR/fullchain.pem" \
    -subj "/CN=$DOMAIN"
fi
exec nginx -g 'daemon off;'
