FROM alpine@sha256:6a92cd1fcdc8d8cdec60f33dda4db2cb1fcdcacf3410a8e05b3741f44a9b5998

USER root

RUN ["apk", "--no-cache", "upgrade"]
RUN ["apk", "--no-cache", "add", "tini"]
RUN ["apk", "--no-cache", "--repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing", "add", "nginx-naxsi", "nginx-naxsi-mod-http-naxsi", "nginx-naxsi-mod-http-xslt-filter", "nginx-naxsi-mod-http-geoip"]

RUN ["install", "-d", "/etc/nginx/ssl"]

RUN apk add openssl \
    && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN ["install", "-d", "/app"]
ADD src/docker-startup.sh /app
ADD src/files/naxsi*.rules /etc/nginx/
ADD src/files/authorized_ip /etc/nginx/
ADD src/files/*.conf /etc/nginx/conf.d/
ADD src/files/sites.nginx /etc/nginx/conf.d/notifications.conf
COPY src/files/nginx_conf /etc/nginx/nginx.conf

EXPOSE 443

WORKDIR /app

ENTRYPOINT ["tini", "--"]

CMD ["./docker-startup.sh"]
