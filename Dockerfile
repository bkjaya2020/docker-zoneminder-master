FROM ubuntu:disco
MAINTAINER B.K.Jayasundera

# Update base packages
RUN apt update \
    && apt upgrade --assume-yes

# Install pre-reqs
RUN apt install -y gnupg
RUN apt-get update \
    && apt-get -y --no-install-recommends install
     
ARG DEBIAN_FRONTEND=noninteractive

# Configure Zoneminder PPA
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 \
    && echo deb http://ppa.launchpad.net/iconnor/zoneminder-master/ubuntu disco main  > /etc/apt/sources.list.d/zoneminder.list \
    && apt update

RUN apt update && apt install -y msmtp


# Install zoneminder
RUN apt install --assume-yes zoneminder 


RUN rm /etc/mysql/my.cnf

RUN cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf
    
# Set our volumes before we attempt to configure apache
VOLUME /var/cache/zoneminder/events /var/lib/mysql /var/log/zm

RUN chmod 740 /etc/zm/zm.conf \
 && chown root:www-data /etc/zm/zm.conf \
 && adduser www-data video \
 && a2enmod cgi \
 && a2enconf zoneminder \
 && a2enmod rewrite \
 && chown -R www-data:www-data /usr/share/zoneminder/ \
 && ln -s /usr/bin/msmtp /usr/sbin/sendmail

# Expose http port
EXPOSE 80

COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh 
ENTRYPOINT ["/entrypoint.sh"]
