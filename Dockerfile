FROM debian:jessie
MAINTAINER King-On Yeung <koyeung@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV FTP_USER ftpuser

# patch sources.list to include package sources
RUN sed -e 's/^deb/deb-src/' < /etc/apt/sources.list >> /etc/apt/sources.list

# install package building helpers, dependencies
RUN apt-get update  && \
    apt-get install -y apt-utils  && \
    apt-get install -y dpkg-dev debhelper  && \
    apt-get build-dep -y openssl pure-ftpd  && \
    apt-get install -y openbsd-inetd  && \
    apt-get clean

# build from source
# reference: [snasello/docker-pureftp](https://github.com/snasello/docker-pureftp)
RUN mkdir /tmp/pure-ftpd/  && \
	cd /tmp/pure-ftpd/  && \
	apt-get source pure-ftpd  && \
	cd pure-ftpd-*  && \
	sed -i '/^optflags=/ s/$/ --without-capabilities/g' ./debian/rules  && \
	dpkg-buildpackage -b -uc

# install the new deb files, and prevent upgrading
RUN dpkg -i /tmp/pure-ftpd/pure-ftpd-common*.deb  && \
    dpkg -i /tmp/pure-ftpd/pure-ftpd_*.deb  && \
    apt-mark hold pure-ftpd pure-ftpd-common

# Setup account
RUN /usr/sbin/useradd -m ${FTP_USER} -s /bin/bash
RUN touch /etc/pure-ftpd/pureftpd.passwd  && \
    pure-pw mkdb

VOLUME ["/home/${FTP_USER}"]

EXPOSE 21/tcp 30000-30009/tcp
CMD /usr/sbin/pure-ftpd -p "30000:30009" -E -R -j -d -l puredb:/etc/pure-ftpd/pureftpd.pdb
