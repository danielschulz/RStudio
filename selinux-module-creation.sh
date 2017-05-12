#!/usr/bin/env bash

export ORIGINAL_DIR=${PWD}
export SEED=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c5; echo;)
export FILENAME="changes-${SEED}.txt"

cd /tmp
cat > ./${FILENAME} << '__EOF__'
#============= init_t ==============
allow init_t pulseaudio_home_t:file getattr;

#!!!! The file '/usr/bin/bash' is mislabeled on your system.
#!!!! Fix with $ restorecon -R -v /usr/bin/bash
allow init_t ssh_home_t:file getattr;

#!!!! WARNING 'init_t' is not allowed to write or create to tmp_t.  Change the label to init_tmp_t.
allow init_t tmp_t:sock_file { getattr write };
allow init_t user_home_t:file { open setattr write };
allow init_t user_home_t:lnk_file { getattr read };
allow init_t xauth_home_t:file getattr;
__EOF__

sudo audit2allow -a -M rserver-${SEED} < /tmp/${FILENAME}
sudo semodule -i "/tmp/rserver-${SEED}.pp"
sudo setenforce 1
getenforce

cd ${ORIGINAL_DIR}
