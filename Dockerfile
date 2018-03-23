FROM registry.centos.org/centos/centos:7

# add RUN label in image to generate report for container-capabilities-scanner
LABEL RUN='docker run --privileged -d $IMAGE'

# touch /usr/bin/yum inside container image to modify the file time (mtime)
# this will report issue via $rpm -V yum
RUN touch /usr/bin/yum

# Install pip and an older version of pip package so that
# misc-package update scanner can report outdated pip packages
RUN yum -y install python-pip && yum clean all
RUN pip install django=1.11.2
