#!/bin/bash
set -e
if [ -e /tmp/plugins/plugins.zip ]
apt-get update
apt-get install -y unzip
then
    unzip  /tmpPlugins/plugins.zip -d /plugins/
fi

cd /
./entrypoint.sh $*

