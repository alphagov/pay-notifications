#!/usr/bin/env ash

set -e

SITE_CONFIG="/etc/nginx/conf.d/notifications.conf"
NGINX_CONFIG="/etc/nginx/nginx.conf"

DD_CONNECTOR_URL=${DD_CONNECTOR_URL:-"https://localhost:5000"}
CONNECTOR_URL=${CONNECTOR_URL:-"https://localhost:5001"}
DNS_RESOLVER_IP=${DNS_RESOLVER_IP:-"169.254.0.2"}
PORT=${PORT:-"8080"}

sed -i "s,DD_CONNECTOR_URL,${DD_CONNECTOR_URL},g" $SITE_CONFIG
sed -i "s,CONNECTOR_URL,${CONNECTOR_URL},g" $SITE_CONFIG
sed -i "s,DNS_RESOLVER_IP,${DNS_RESOLVER_IP},g" $SITE_CONFIG
sed -i "s,PORT,${PORT},g" $SITE_CONFIG
sed -i "s,listen \[::\]:80 default_server;,,g" "/etc/nginx/conf.d/default.conf"


exec nginx -g "daemon off;"
