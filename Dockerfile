FROM ubuntu:22.04
LABEL maintainer="carolle"
RUN apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        nginx=1.18.0-6ubuntu14.4 && \
    rm -rf /var/www/html/*
EXPOSE 80
COPY ./battleboat_files/ /var/www/html/
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]

