#!/bin/sh
#
# Copyright (c) 2021, Rackslab
#
# GNU General Public License v3.0+

machinectl pull-raw https://hub.nspawn.org/storage/debian/bullseye/raw/image.raw.xz admin

for HOST in front cn1 cn2; do
  machinectl clone admin ${HOST}
done
machinectl list-images

for HOST in admin front cn1 cn2; do
  cat <<EOF >/etc/systemd/nspawn/${HOST}.nspawn
[Network]
Private=yes
VirtualEthernet=yes
Zone=hpc
EOF
done

for HOST in admin front cn1 cn2; do
  machinectl start ${HOST}
done

# install python
for HOST in admin front cn1 cn2; do
  machinectl shell ${HOST} /usr/bin/apt install -y python3
done

ansible all -m ping
ansible-playbook conf/site.yml
