FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11

USER root

RUN ["apk", "--no-cache", "add", "openssl", "tini", "nginx=1.22.1-r0", "nginx-mod-http-naxsi=1.22.1-r0", "nginx-mod-http-xslt-filter=1.22.1-r0", "nginx-mod-http-geoip=1.22.1-r0"]

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
