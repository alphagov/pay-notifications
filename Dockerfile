FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454

USER root

RUN ["apk", "--no-cache", "add", "openssl", "tini", "nginx=1.20.2-r1", "nginx-mod-http-naxsi=1.20.2-r1", "nginx-mod-http-xslt-filter=1.20.2-r1", "nginx-mod-http-geoip=1.20.2-r1"]

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
