#!/bin/bash
set -e
if [ -f /tmpPlugins/plugins.zip ]
then
    apt-get update
    apt-get install -y unzip
    unzip  /tmpPlugins/plugins.zip -d /plugins/
fi

cd /
./entrypoint.sh $*

