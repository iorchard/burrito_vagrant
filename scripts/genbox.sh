#!/bin/bash

set -eo pipefail

CLOUD_IMG_FILENAME=$(basename ${CLOUD_IMG})
VERSIONS=$(echo $CLOUD_IMG_FILENAME|cut -d'-' -f3)
BURRITO_VERSION=${VERSIONS%_*}
OS_VERSION=${VERSIONS#*_}
BOX_FILENAME="${CLOUD_IMG_FILENAME%.*}.box"
USERPW="${USERPW:-vagrant}"

${WORKSPACE}/scripts/prepare.sh

cp ${CLOUD_IMG} ${OUTPUT_DIR}/box.img

pushd ${OUTPUT_DIR}
  IMG_SIZE=$(qemu-img info --output=json "${OUTPUT_DIR}/box.img" | awk '/^\s{0,4}"virtual-size/{s=int($2)/(1024^3); print (s == int(s)) ? s : int(s)+1 }')
  cat > metadata.json <<EOF
{
    "provider": "libvirt",
    "format": "qcow2",
    "virtual_size": ${IMG_SIZE}
}
EOF
  cat > info.json <<EOF
{
  "author": "Heechul Kim",
  "homepage": "https://github.com/iorchard/burrito_vagrant",
  "burrito_version": "${BURRITO_VERSION}",
  "os_version": "Rocky Linux ${OS_VERSION}"
}
EOF
  cat > Vagrantfile <<EOF
Vagrant.configure("2") do |config|
       config.vm.provider :libvirt do |libvirt|
       libvirt.driver = "kvm"
       libvirt.host = 'localhost'
       libvirt.uri = 'qemu:///system'
       end
config.vm.define "new" do |burritobox|
       burritobox.vm.box = "iorchard/burrito"
       burritobox.vm.provider :libvirt do |burritovm|
       burrito.cpus = 1
       burritovm.memory = 1024
       end
       end
end
EOF
  virt-customize \
        -a box.img \
        --root-password disabled \
	--password-crypto sha512 \
        --password clex:password:${USERPW}
  [[ -f ${BOX_FILENAME} ]] && rm -f ${BOX_FILENAME} || :
  tar cv -S --totals metadata.json info.json Vagrantfile box.img | \
    pigz -c > "${BOX_FILENAME}"  
  #${WORKSPACE}/scripts/create_box.sh ${CLOUD_IMG_FILENAME}
  rm box.img
  BOX_CHECKSUM=$(sha256sum ${BOX_FILENAME}|cut -d' ' -f1)
  cat << EOF > catalog.json
{
   "name" : "iorchard/burrito",
   "description" : "Burrito vagrant box.",
   "versions" : [
      {
         "version" : "${BURRITO_VERSION}",
         "providers" : [
            {
               "name" : "libvirt",
               "url" : "file://${OUTPUT_DIR}/${BOX_FILENAME}",
               "checksum_type": "sha256",
               "checksum": "${BOX_CHECKSUM}"
            }
         ]
      }
   ]
}
EOF
popd
