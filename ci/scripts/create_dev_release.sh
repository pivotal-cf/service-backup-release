#!/bin/bash -e

cd $(dirname $0)/../..
bosh -n create release --name service-backup --with-tarball
