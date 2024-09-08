ARG         FROM=docker.io/library/debian:bookworm-slim
FROM        ${FROM}

ENV         WORKSPACE="/burrito_vagrant"
ENV         OUTPUT_DIR="/tmp/box_output"
WORKDIR     ${WORKSPACE}

COPY        scripts ${WORKSPACE}/scripts

VOLUME      ["${OUTPUT_DIR}"]

ENTRYPOINT  ["/burrito_vagrant/scripts/genbox.sh"]

