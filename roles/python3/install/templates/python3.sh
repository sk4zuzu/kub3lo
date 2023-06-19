#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

if [[ -f /etc/alpine-release ]]; then
    apk --no-cache --no-progress add python3
    exit
fi

if [[ -f /etc/debian_version ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y python3
    exit
fi
