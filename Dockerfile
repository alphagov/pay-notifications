FROM alpine:3.21.0@sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45

RUN apk -U upgrade --available

USER root

RUN apk --no-cache add \
    openssl \
    aws-cli \
    tini \
    nginx=1.26.2-r3 \
    nginx-mod-http-naxsi=1.26.2-r3 \
    nginx-mod-http-xslt-filter=1.26.2-r3 \
    nginx-mod-http-geoip=1.26.2-r3

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
