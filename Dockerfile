FROM centos:centos7
MAINTAINER Daniel Schulz

RUN mkdir -p /apps/sw/tmp && \
    yum install -y wget nettools netcat ping htop \
    curl time sed gcc dkms make cmake bzip2 perl git zip unzip nano bcrypt \
    python-setuptools python-jpype iputils-ping netcat

WORKDIR /apps/sw/tmp

ARG RSTUDIO_SERVER_URL="https://download2.rstudio.org/rstudio-server-rhel-1.1.463-x86_64.rpm"
ARG EPEL_RELEASE_URL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"

RUN cd /apps/sw/tmp && \
    rpm -Uvh ${EPEL_RELEASE_URL} && \
    yum clean all && \
    yum install -y R && \
    yum install -y --nogpgcheck ${RSTUDIO_SERVER_URL} && \
    yum clean all && \
    sed -i -e "s|^\. \/etc\/rc\.d\/init\.d\/functions$|#. /etc/rc.d/init.d/functions|g" /etc/init.d/rstudio-server && \
    sed -i -e "s|daemon \$rserver$|\$rserver|g" /etc/init.d/rstudio-server


ARG ACC_GROUP_NAME=datascientists
ARG ACC_GROUP_GID=1024
ARG ACC_USER_NAME=datascientist
ARG ACC_USER_UID=1024
ARG ACC_USER_PASSWORD=password

RUN groupadd -g ${ACC_GROUP_GID} ${ACC_GROUP_NAME} && \
    useradd -g ${ACC_GROUP_NAME} -u ${ACC_USER_UID} ${ACC_USER_NAME} -m -d /home/${ACC_USER_NAME} -s /bin/bash && \
    usermod -aG wheel ${ACC_USER_NAME} && \
    echo "${ACC_USER_NAME}:${ACC_USER_PASSWORD}" | chpasswd
    # sed -i "s|^root\s*ALL=(ALL)\s*ALL$|root ALL=(ALL) ALL \n${ACC_USER_NAME} ALL=(ALL) ALL|g" /etc/sudoers && \

RUN mkdir -p /apps/data /apps/tmp && \
    chmod 775 -R /apps && \
    chmod 777 -R /apps/tmp && \
    chmod 700 -R /home/${ACC_USER_NAME} && \
    chown ${ACC_USER_UID}:${ACC_GROUP_GID} -R /apps

USER ${ACC_USER_UID}:${ACC_GROUP_GID}

EXPOSE 80

ENTRYPOINT rstudio-server start && tail -f /dev/null
