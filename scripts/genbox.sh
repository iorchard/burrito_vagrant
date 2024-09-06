#!/bin/bash
CLOUD_IMG_FILENAME=$(basename ${CLOUD_IMG})

${WORKSPACE}/scripts/prepare.sh

cp ${CLOUD_IMG} /output/

pushd /output
  ${WORKSPACE}/scripts/create_box.sh ${CLOUD_IMG_FILENAME}
  rm ${CLOUD_IMG_FILENAME}
  chown ${OWNER_ID}:${OWNER_GRP} .
popd
