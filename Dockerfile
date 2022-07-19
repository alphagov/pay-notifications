FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872

USER root

RUN ["apk", "--no-cache", "add", "openssl", "tini", "nginx=1.22.0-r0", "nginx-mod-http-naxsi=1.22.0-r0", "nginx-mod-http-xslt-filter=1.22.0-r0", "nginx-mod-http-geoip=1.22.0-r0"]

RUN ["install", "-d", "/etc/nginx/ssl"]

RUN openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 &>/dev/null \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN ["install", "-d", "/app"]
COPY src/docker-startup.sh /app
COPY src/files/naxsi*.rules /etc/nginx/
COPY src/files/authorized_ip /etc/nginx/
COPY src/files/sites.nginx /etc/nginx/conf.d/notifications.conf
COPY src/files/nginx_conf /etc/nginx/nginx.conf

EXPOSE 443

WORKDIR /app

ENTRYPOINT ["tini", "--"]

CMD ["./docker-startup.sh"]
