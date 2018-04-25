#!/usr/bin/env ash

set -e

SITE_CONFIG="/etc/nginx/conf.d/notifications.conf"
NGINX_CONFIG="/etc/nginx/nginx.conf"

DD_CONNECTOR_URL=${DD_CONNECTOR_URL:-"https://localhost:5000"}
CONNECTOR_URL=${CONNECTOR_URL:-"https://localhost:5001"}

sed -i "s,DD_CONNECTOR_URL,${DD_CONNECTOR_URL},g" $SITE_CONFIG
sed -i "s,CONNECTOR_URL,${CONNECTOR_URL},g" $SITE_CONFIG

nginx -g "daemon off;"
