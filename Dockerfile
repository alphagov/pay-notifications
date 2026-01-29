FROM alpine:3.23.3@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659

RUN apk -U upgrade --available

USER root

RUN apk --no-cache add \
    openssl \
    aws-cli \
    tini \
    nginx~=1.28 \
    nginx-mod-http-naxsi~=1.28 \
    nginx-mod-http-xslt-filter~=1.28 \
    nginx-mod-http-geoip~=1.28

RUN install -d /etc/nginx/ssl

# forward request and error logs to docker log collector
RUN openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 &>/dev/null \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN install -d /app
COPY src/docker-startup.sh /app
COPY src/files/authorized_ip /etc/nginx/
COPY src/files/sites.nginx /etc/nginx/conf.d/notifications.conf
COPY src/files/nginx_conf /etc/nginx/nginx.conf
# For testing and development -- overwritten by real rules when deployed
COPY tests/rules-stub.naxsi /etc/nginx/naxsi.rules

EXPOSE 443

WORKDIR /app

ENTRYPOINT ["tini", "--"]

CMD ["./docker-startup.sh"]
