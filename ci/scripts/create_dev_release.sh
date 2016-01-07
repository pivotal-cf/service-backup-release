#!/bin/bash -e

bosh -n create release --name service-backup --with-tarball
