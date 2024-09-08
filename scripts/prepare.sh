#!/bin/bash

apt update
DEBIAN_FRONTEND=noninteractive apt -y install \
    qemu-utils psmisc pigz libguestfs-tools

