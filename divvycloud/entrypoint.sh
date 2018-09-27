#!/bin/bash
set -e
if [ -e /tmp/plugins/plugins.zip ]
then
    unzip  /tmp/plugins/plugins.zip -d /plugins/
fi

exec "$@"
