FROM centos:centos7
MAINTAINER Daniel Schulz <danielschulz2005@hotmail.com>

ARG RSTUDIO_SERVER_URL="https://download2.rstudio.org/rstudio-server-rhel-1.0.136-x86_64.rpm"
ARG EPEL_RELEASE_URL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
RUN mkdir -p /apps/sw/tmp && \
    yum install -y wget

WORKDIR /apps/sw/tmp

RUN cd /apps/sw/tmp
RUN rpm -Uvh ${EPEL_RELEASE_URL}
RUN yum clean all
RUN yum install -y R
RUN yum install -y --nogpgcheck ${RSTUDIO_SERVER_URL}
RUN yum clean all

RUN sed -i -e "s|^\. \/etc\/rc\.d\/init\.d\/functions$|#. /etc/rc.d/init.d/functions|g" /etc/init.d/rstudio-server
RUN sed -i -e "s|daemon \$rserver$|\$rserver|g" /etc/init.d/rstudio-server

EXPOSE 80

ENTRYPOINT rstudio-server start && tail -f /dev/null
