#!/bin/bash
#
for n in service mgmt overlay provider storage; do
  sudo virsh net-define ${n}.xml
  sudo virsh net-start ${n}
  sudo virsh net-autostart ${n}
done

