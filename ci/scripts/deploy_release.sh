#!/bin/bash -eu

bosh --non-interactive --target $BOSH_URL --ca-cert $BOSH_CA_CERT_PATH --deployment $MANIFEST deploy
