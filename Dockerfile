FROM alpine:3.4

ENV NGINX_VERSION 1.16.1

RUN apk add --update tcpdump

COPY ./upload/ /usr/src/

COPY install.sh /usr/src/
COPY create_date_folders.sh /usr/src/
COPY nginx.key /usr/src/

RUN sh -x /usr/src/install.sh
RUN sh -x /usr/src/create_date_folders.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY nginx.vh.backend.conf /etc/nginx/conf.d/backend.conf

RUN rm -r /usr/src/
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
