#!/usr/bin/env ash

set -e

SITE_CONFIG="/etc/nginx/conf.d/notifications.conf"
NGINX_CONFIG="/etc/nginx/nginx.conf"

DD_CONNECTOR_URL=${DD_CONNECTOR_URL:-"https://localhost:5000"}
CONNECTOR_URL=${CONNECTOR_URL:-"https://localhost:5001"}

sed -i "s,DD_CONNECTOR_URL,${DD_CONNECTOR_URL},g" $SITE_CONFIG
sed -i "s,CONNECTOR_URL,${CONNECTOR_URL},g" $SITE_CONFIG

# Generate a selfsigned key and certificate if we don't have one
if [ ! -f /etc/keys/crt ]; then
  dir=`mktemp -d`
  openssl req -x509 -days 1000 -newkey rsa:2048 -nodes -subj '/CN=notifications' -keyout "$dir/key" -out "$dir/crt"
  mkdir -p /etc/keys
  install -m 0600 -o nginx -g nginx "$dir/key" /etc/keys/key
  install -m 0644 -o nginx -g nginx "$dir/crt" /etc/keys/crt
  rm -rf "$dir"
fi

exec nginx -g "daemon off;"
