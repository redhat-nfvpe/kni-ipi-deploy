#!/bin/bash

OUTPUT_DIR="generated"

CONTAINER_NAME="ipi-dnsmasq-bm"
PROJECT_DIR="$HOME/kni-ipi-deploy"

# shellcheck disable=SC1091
source "../settings.sh"

mkdir -p "$OUTPUT_DIR"/bm/etc/dnsmasq.d
mkdir -p "$OUTPUT_DIR"/bm/var/run
 
envsubst < dnsmasq.conf.tmpl > "${OUTPUT_DIR}"/bm/etc/dnsmasq.d/dnsmasq.conf
envsubst < dnsmasq.hostsfile.tmpl > "${OUTPUT_DIR}"/bm/etc/dnsmasq.d/dnsmasq.hostsfile

CONTAINER_NAME="ipi-dnsmasq-bm"
CONTAINER_IMAGE="quay.io/poseidon/dnsmasq"

podman run -d --name "$CONTAINER_NAME" --net=host \
            -v "$PROJECT_DIR/dhcp/$OUTPUT_DIR/bm/var/run:/var/run/dnsmasq:Z" \
            -v "$PROJECT_DIR/dhcp/$OUTPUT_DIR/bm/etc/dnsmasq.d:/etc/dnsmasq.d:Z" \
            --expose=53 --expose=53/udp --expose=67 --expose=67/udp --expose=69 \
            --expose=69/udp --cap-add=NET_ADMIN "$CONTAINER_IMAGE" \
            --conf-file=/etc/dnsmasq.d/dnsmasq.conf -u root -d -q
