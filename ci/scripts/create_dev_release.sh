#!/bin/bash -eu

cd $(dirname $0)/../..
bosh --non-interactive create release --name service-backup --with-tarball --timestamp-version
bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH cleanup
bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH upload release
