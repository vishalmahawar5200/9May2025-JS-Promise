FROM ubuntu:latest

RUN apt-get update && apt-get install -y apache2

WORKDIR /var/www/html

#COPY source destination
COPY . .

EXPOSE 80

CMD [ "usr/sbin/apache2ctl","-D","FOREGROUND"]