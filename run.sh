#!/bin/bash

OUTPUT_DIR="/tmp/box_output"
CR=$(type -p podman)

#      --user ${OWNER_ID}:${OWNER_GRP} \
#      --userns keep-id:uid=${OWNER_ID},gid=${OWNER_GRP} \
function run() {
  _check "$@"
  ${CR} build -t docker.io/jijisa/burrito-vagrant .
  ${CR} run -it --rm \
      -v ${OUTPUT_DIR}:${OUTPUT_DIR} -v ${CLOUD_IMG}:${CLOUD_IMG} \
      --env CLOUD_IMG=${CLOUD_IMG} \
      --entrypoint=/bin/bash \
      docker.io/jijisa/burrito-vagrant 
}
function build() {
  _check "$@"
  ${CR} build -t docker.io/jijisa/burrito-vagrant .
  ${CR} run -it --rm \
      -v ${OUTPUT_DIR}:${OUTPUT_DIR} -v ${CLOUD_IMG}:${CLOUD_IMG} \
      --env CLOUD_IMG=${CLOUD_IMG} --env-file .env \
      docker.io/jijisa/burrito-vagrant 
}
function _check() {
  CLOUD_IMG=${1}
  if [[ -z ${CLOUD_IMG} ]] || [[ ! -f ${CLOUD_IMG} ]]; then
      echo "Abort) cannot find ${CLOUD_IMG}." 1>&2
      USAGE
      exit 1
  fi

  mkdir -p ${OUTPUT_DIR}
}

function USAGE() {
  cat << EOF 1>&2
  USAGE: $0 [-h|-b|-r] [CLOUD_IMAGE]
  
   -h --help                       Display this help message.
   -b --build BURRITO_CLOUD_IMAGE  Build burrito iso.
   -r --run BURRITO_CLOUD_IMAGE    Run and go into the container.
  
  ex) $0 --build /path/to/cloud_image_file
EOF
}
if [ $# -lt 1 ]; then
  USAGE
  exit 1
fi
OPT=$1
shift
while true
do
  case "$OPT" in
    -h | --help)
      USAGE
      exit 0
      ;;
    -b | --build)
      build "$@"
      break
      ;;
    -r | --run)
      run "$@"
      break
      ;;
    *)
      echo Error: unknown option: "$OPT" 1>&2
      USAGE
      exit 1
      ;;
  esac
done
