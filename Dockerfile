
#os
FROM ubuntu

# libraries

RUN apt-get update
RUN apt-get -y install python3
RUN apt-get -y install python3-pip
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install apache2
RUN apt-get -y install libapache2-mod-wsgi-py3

# dependencies of gamesever
COPY ./gameServer/requirements.txt /var/www/gameServer/gameServer/requirements.txt
RUN pip3 install flask-assets
RUN pip3 install -r /var/www/gameServer/gameServer/requirements.txt

# setting up apache
COPY ./gameServer.conf /etc/apache2/sites-available/gameServer.conf

RUN a2ensite gameServer
RUN a2enmod wsgi
RUN a2enmod headers
RUN service apache2 restart

COPY ./gameServer.wsgi /var/www/gameServer/gameServer.wsgi
COPY ./run.py /var/www/gameServer/run.py
COPY ./gameServer /var/www/gameServer/gameServer/

RUN a2dissite 000-default.conf
RUN a2ensite gameServer.conf

#link apacke config to docker logs
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

EXPOSE 80
WORKDIR /var/www/gameServer/

CMD /usr/sbin/apache2ctl -D FOREGROUND

