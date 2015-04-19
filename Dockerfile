FROM tianon/docker-brew-ubuntu-core
MAINTAINER Michael Clovis ms.clovis@verizon.net
#
#
#

RUN mkdir -p /tmp/mike/ && \
touch /tmp/mike/memory && \
fallocate -l 1G /tmp/mike/memory && \
rm -Rf /tmp/mike/

ENV HOME /root


WORKDIR /root
ENV TERM xterm


### Load programs that are from the repositories first

ADD DV* /root/




RUN \
apt-get update && \
apt-get install -y  wget curl telnet vim nano man-db  \
postgresql-9.3 postgresql-client-9.3 maven2 nginx apache2 openssh-server openssh-client git language-pack-en 1> /dev/null && \
apt-get purge -y openjdk-* && \
apt-get autoclean && \

# make the necessary directoryies
mkdir -p /data/db/postgresql/ && \
mkdir -p /data/db/mongodb/logs && \
mkdir -p /root/.nvm && \
mkdir -p /var/run/sshd && \
chown -R root:root /data && \



#set up the working environment

locale-gen en_US.UTF-8 && \

update-locale LANG=en_US.UTF-8 && \



# adjust some existing files


cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak && \
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \

# after removing open jdk above
# finish adding Oracle sdk 1.8

mv jdk /opt  && \
chown -R root:root /opt/jdk && \
update-alternatives --quiet --install "/usr/bin/java" "java"  "/opt/jdk/jdk1.8.0_40/jre/bin/java" 1  && \

#add newest Jetty by hand due to issue in repositories

mv jetty /opt && \
ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty && \

addgroup --quiet --system jetty && \
adduser --quiet --system --ingroup jetty jetty && \

chmod 777 .bashrc && \
mv jettyfile /etc/default/jetty && \
chown -R jetty:jetty /opt/jetty && \

#reconfigure postgresql server to have the data files in /data/db/postgresql .
# This will make both current DBs reside in a directory that can be made a volume (data is preserved on the host)

pg_dropcluster 9.3 main && \
pg_createcluster -d /data/db/postgresql 9.3 main  && \


# Lastly add Newest version of MongoDB by hand due to current issue in repositories


mv mongod /etc/init.d/mongod && \

mkdir -p /opt/mongodb && \
mv mongodb-linux-x86_64-ubuntu1404-3.0.2  /opt/mongodb/3.0.2 && \
mv mongod.conf /etc/  && \
ln -s /opt/mongodb/3.0.2 /opt/mongodb/current && \
ln -s /opt/mongodb/current/bin/mongod /usr/bin/mongod && \

#clean up to slim down image size


apt-get clean -y && \
apt-get autoclean -y && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* && \

#change root password to dev, users of the build can change this.


echo 'root:dev' | chpasswd















