#!/bin/bash -eu

export BOSH_CA_CERT_PATH=$(readlink -f $BOSH_CA_CERT_PATH)

cd $(dirname $0)/../..
bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH --deployment $MANIFEST deploy
