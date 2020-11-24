FROM webdevops/php-nginx:7.2
MAINTAINER  LX

ADD apps /app/

RUN mkdir -pv /var/log/nginx && touch /var/log/nginx/error.log && chmod 777 -R /app && chmod 777 -R /var/log/nginx/error.log


ADD 10-php.conf /opt/docker/etc/nginx/vhost.common.d/10-php.conf

ADD vhost.conf /opt/docker/etc/nginx/vhost.conf
ADD 10-location-root.conf /opt/docker/etc/nginx/vhost.common.d/10-location-root.conf




#CMD ["nginx", "-g", "daemon off;"]


#CMD ["php-fpm7.2", "-F", "-R;"] 

#CMD php7.2-fpm restart && nginx -g "daemon off;"

#CMD ["/usr/bin/php-fpm7.2", "-D;"  "nginx;"]

RUN apt-get -y update
RUN apt-get install -y python-setuptools
RUN apt-get install -y supervisor
ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]


