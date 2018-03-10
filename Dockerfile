# Xenial Xerus
FROM phusion/baseimage:latest
ARG ver=3.9.3

ENV DEBIAN_FRONTEND noninteractive


# Bring in the latest and greatest
RUN apt-get dist-upgrade
RUN apt-get update --fix-missing && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

RUN curl -sS https://dl.ubnt.com/firmwares/ufv/v$ver/unifi-video.Ubuntu16.04_amd64.v$ver.deb > /tmp/unifi-video.deb

# Install unifi-video dependencies and the core package itself
RUN apt-get install -y mongodb-server openjdk-8-jre-headless jsvc sudo
RUN dpkg -i /tmp/unifi-video.deb && rm /tmp/unifi-video.deb
RUN apt-get update && apt-get -f install

RUN sed -i -e 's/^log/#log/' /etc/mongodb.conf
RUN printf "syslog = true" | tee -a /etc/mongodb.conf

RUN mkdir /etc/service/mongodb /etc/service/unifi-video
RUN printf "#!/bin/sh\nexec /sbin/setuser mongodb /usr/bin/mongod --config /etc/mongodb.conf" | tee /etc/service/mongodb/run
RUN printf "#!/bin/sh\nexec /usr/sbin/unifi-video --nodetach start" | tee /etc/service/unifi-video/run
RUN chmod 500 /etc/service/mongodb/run /etc/service/unifi-video/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Interfaces to outside
VOLUME ["/var/lib/mongodb", "/var/lib/unifi-video", "/var/log/unifi-video"]
EXPOSE 6666 7080 7442 7443 7445 7446 7447

CMD ["/sbin/my_init"]

# docker run -d --privileged \
# -v ~/Applications/unifi-video/mongodb:/var/lib/mongodb \
# -v ~/Applications/unifi-video/unifi-video:/var/lib/unifi-video \
# -v ~/Applications/unifi-video/log:/var/log/unifi-video \
# -p 6666:6666 \
# -p 7080:7080 \
# -p 7442:7442 \
# -p 7443:7443 \
# -p 7445:7445 \
# -p 7446:7446 \
# -p 7447:7447 \
# --name unifi-video_3.9.3 \
# --restart=unless-stopped \
# melser/unifi-video:3.9.3