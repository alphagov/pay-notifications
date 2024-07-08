#!/usr/bin/env ash

set -e

SITE_CONFIG="/etc/nginx/conf.d/notifications.conf"
NGINX_CONFIG="/etc/nginx/nginx.conf"
NAXSI_CONFIG="$(dirname ${NGINX_CONFIG})/naxsi.rules"

CONNECTOR_URL=${CONNECTOR_URL:-"https://localhost:5001"}
NGINX_RESOLVER=${NGINX_RESOLVER:-"172.18.0.2"}

sed -i "s,CONNECTOR_URL,${CONNECTOR_URL},g" $SITE_CONFIG
sed -i "s,NGINX_RESOLVER,${NGINX_RESOLVER},g" $SITE_CONFIG

# Generate a selfsigned key and certificate if we don't have one
if [ ! -f /etc/keys/crt ]; then
  dir=`mktemp -d`
  openssl req -x509 -days 1000 -newkey rsa:2048 -nodes -subj '/CN=notifications' -keyout "$dir/key" -out "$dir/crt"
  mkdir -p /etc/keys
  install -m 0600 -o nginx -g nginx "$dir/key" /etc/keys/key
  install -m 0644 -o nginx -g nginx "$dir/crt" /etc/keys/crt
  rm -rf "$dir"
fi

# Download or copy in the naxsi rules.

if [[ -n "$AWS_REGION" && -n "$ENVIRONMENT" ]]
then
  # BUCKET govuk-pay-naxsi-rules-eu-west-1-test
  # FILE   test-12-notifications-fargate_naxsi.rules
  BUCKET="govuk-pay-naxsi-rules-${AWS_REGION}-${ENVIRONMENT%%-*}"
  FILE="${ENVIRONMENT}-notifications-fargate_naxsi.rules"

  for try in 1 2 3 4 5
  do
    echo "copying ${AWS_REGION}.amazonaws.com/${BUCKET}/${FILE} to ${NAXSI_CONFIG} (${try}/5)"
    if aws s3 cp --region "${AWS_REGION}" --endpoint-url https://s3-"${AWS_REGION}".amazonaws.com "${BUCKET}/${FILE}" "${NAXSI_CONFIG}"
    then
      COMPLETE=true
      break
    fi
  done

  if test -z "$COMPLETE" 
  then
    echo "Failed to download naxsi config from S3"
    exit 1
  fi
fi

exec nginx -g "daemon off;"
