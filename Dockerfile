FROM registry.centos.org/centos/centos:7

ARG VERSION=1.0-SNAPSHOT

# add RUN label in image to generate report for container-capabilities-scanner
LABEL RUN='docker run --privileged -d $IMAGE'

# touch /usr/bin/yum inside container image to modify the file time (mtime)
# this will report issue via $rpm -V yum
RUN touch /usr/bin/yum

ENV JAVA_HOME /etc/alternatives/jre
ENV CHE_STARTER_HOME /opt/che-starter

## Default ENV variable values
ENV OSO_ADDRESS tsrv.devshift.net:8443
ENV OSO_DOMAIN_NAME tsrv.devshift.net
ENV KUBERNETES_CERTS_CA_FILE /opt/che-starter/tsrv.devshift.net.cer

# took off the yum -y update command from following operation
# so that pipeline-scanner can report few rpm update information
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel git && \
    yum clean all

WORKDIR $CHE_STARTER_HOME

RUN git clone https://github.com/almighty/InstallCert.git && \
     javac $CHE_STARTER_HOME/InstallCert/InstallCert.java

RUN chown -R 1000:0 ${CHE_STARTER_HOME} && chmod -R ug+rw ${CHE_STARTER_HOME}

ADD docker-entrypoint.sh $CHE_STARTER_HOME

VOLUME /tmp

ADD target/che-starter-$VERSION.jar $CHE_STARTER_HOME/app.jar

# Install pip and an older version of pip package so that
# misc-package update scanner can report outdated pip packages
RUN yum -y install python-pip && yum clean all
RUN pip install django=1.11.2

EXPOSE 10000

ENTRYPOINT ["/opt/che-starter/docker-entrypoint.sh"]
