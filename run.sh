#!/bin/bash

OUTPUT_DIR="$(pwd)/output"

function USAGE() {
  echo "USAGE: $0 [-h|-b|-r] [CLOUD_IMAGE]" 1>&2
  echo
  echo " -h --help                   Display this help message."
  echo " -b --build CLOUD_IMAGE      Build burrito iso."
  echo " -r --run CLOUD_IMAGE        Run and go into the container."
  echo
  echo "ex) $0 --build /path/to/cloud_image_file"
  echo
}
function run() {
  _check "$@"
  docker build -t docker.io/jijisa/burrito-vagrant .
  docker run -it --rm \
      -v $(pwd)/output:/output -v ${CLOUD_IMG}:${CLOUD_IMG} \
      --env OWNER_ID=${OWNER_ID} --env OWNER_GRP=${OWNER_GRP} \
      --env CLOUD_IMG=${CLOUD_IMG} \
      --entrypoint=/bin/bash \
      docker.io/jijisa/burrito-vagrant 
}
function build() {
  _check "$@"
  docker build -t docker.io/jijisa/burrito-vagrant .
  docker run -it --rm \
      -v /tmp/output:/output -v ${CLOUD_IMG}:${CLOUD_IMG} \
      --env OWNER_ID=${OWNER_ID} --env OWNER_GRP=${OWNER_GRP} \
      --env CLOUD_IMG=${CLOUD_IMG} \
      docker.io/jijisa/burrito-vagrant 
}
function _check() {
  CLOUD_IMG=${1}
  if [[ -z ${CLOUD_IMG} ]] || [[ ! -f ${CLOUD_IMG} ]]; then
      echo "Abort) cannot find ${CLOUD_IMG}." 1>&2
      USAGE
      exit 1
  fi
  OWNER_ID=$(id -u)
  OWNER_GRP=$(id -g)

  mkdir -p ${OUTPUT_DIR}
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
