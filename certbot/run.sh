#!/bin/sh
set -e

# Install docker client for nginx reload
apk add --no-cache docker-cli >/dev/null 2>&1

DOMAIN=itbsil.helina.africa
EMAIL="${CERTBOT_EMAIL:?CERTBOT_EMAIL required}"
LIVE_DIR="/etc/letsencrypt/live/$DOMAIN"
BOOTSTRAP_FLAG="/etc/letsencrypt/.issued"

if [ ! -f "$BOOTSTRAP_FLAG" ]; then
  rm -rf \
    /etc/letsencrypt/live/$DOMAIN \
    /etc/letsencrypt/archive/$DOMAIN \
    /etc/letsencrypt/renewal/$DOMAIN.conf
  certbot certonly --webroot -w /var/www/certbot \
    --email "$EMAIL" --agree-tos --no-eff-email \
    --keep-until-expiring --non-interactive --preferred-challenges http \
    -d "$DOMAIN"
  touch "$BOOTSTRAP_FLAG"
fi

while :; do
  if certbot renew --webroot -w /var/www/certbot --quiet --agree-tos --keep-until-expiring; then
    echo "Certificates renewed, reloading nginx..."
    docker exec itb-proxy nginx -s reload || echo "Warning: nginx reload failed"
  fi
  sleep 12h
done
