FROM ubuntu:22.04
MAINTAINER Edward Wang <edward.c.wang@compdigitec.com>

# Basic tools & dependencies
RUN apt-get update && apt-get install -y dumb-init vim wget htop wget curl unzip git
RUN apt-get update && apt-get install -y --no-install-recommends poppler-utils # for pdftotext

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto
RUN apt-get update && apt-get -y install tzdata

# Install apache2 & PHP
RUN apt-get update && apt-get install -y apache2
RUN apt-get update && apt-get install -y libapache2-mod-php
RUN apt-get update && apt-get install -y php-mysql
RUN apt-get update && apt-get install -y php-curl php-imagick
RUN apt-get update && apt-get install -y php-zip # required by SuiteCRM
RUN apt-get update && apt-get install -y php-xml php-mbstring # required by SuiteCRM
RUN apt-get update && apt-get install -y php-imap # required by SuiteCRM
RUN apt-get update && apt-get install -y php-gd # gd for image cropping

# SuiteCRM requires composer
RUN apt-get update && apt-get install -y --no-install-recommends composer

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

# Permissions
RUN chown -R www-data:www-data /var/lock/apache2
RUN chown -R www-data:www-data /var/log/apache2
RUN chown -R www-data:www-data /var/run/apache2

# Change PHP8 max file upload size
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 64M/g" /etc/php/8.1/apache2/php.ini

# Grab SuiteCRM
RUN wget https://github.com/salesagility/SuiteCRM/archive/refs/tags/v7.12.6.tar.gz -O- | tar zxvf -

# Move into hosting dir
RUN rm -rf /var/www/html
RUN mv SuiteCRM-7.12.6 /var/www/html

WORKDIR /var/www/html

# Permissions
RUN chown -R www-data:www-data .

RUN composer install --no-dev

# PHP8 does not permit overwriting $GLOBALS
RUN sed -i "s/\$GLOBALS =/#\$GLOBALS =/g" install/performSetup.php

# Config
COPY config.php .

EXPOSE 80

USER www-data

# Entrypoint
COPY ./entrypoint.sh /
CMD ["dumb-init", "/entrypoint.sh"]
