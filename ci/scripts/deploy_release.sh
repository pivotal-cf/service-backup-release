#!/bin/bash -eu

cd $(dirname $0)/../..
bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH deploy --deployment $MANIFEST
