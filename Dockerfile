FROM alpine:3.18.5@sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0

RUN apk -U upgrade --available

USER root

RUN apk --no-cache add \
    openssl \
    tini \
    nginx=1.24.0-r7 \
    nginx-mod-http-naxsi=1.24.0-r7 \
    nginx-mod-http-xslt-filter=1.24.0-r7 \
    nginx-mod-http-geoip=1.24.0-r7

RUN install -d /etc/nginx/ssl

# forward request and error logs to docker log collector
RUN openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 &>/dev/null \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN install -d /app
COPY src/docker-startup.sh /app
COPY src/files/naxsi*.rules /etc/nginx/
COPY src/files/authorized_ip /etc/nginx/
COPY src/files/sites.nginx /etc/nginx/conf.d/notifications.conf
COPY src/files/nginx_conf /etc/nginx/nginx.conf

EXPOSE 443

WORKDIR /app

ENTRYPOINT ["tini", "--"]

CMD ["./docker-startup.sh"]
