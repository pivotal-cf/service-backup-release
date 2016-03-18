#!/bin/bash -eu

export BOSH_CA_CERT_PATH=$(readlink -f $BOSH_CA_CERT_PATH)

cd $(dirname $0)/../..
bosh --non-interactive create release --name service-backup --timestamp-version
bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH cleanup
bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH upload release
