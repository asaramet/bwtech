#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
#SERVER_FOLDER="asaramet@comserver.hs-esslingen.de:~/.public_html/"

sync()
{
  echo "=== Syncronising to ${SERVER_FOLDER}"
  find .  -maxdepth 1 \( ! -name '.*' ! -name 'package*' ! -name 'node_*' ! -name bin \) -print0 | xargs -0 -I{} \
  basename {} | xargs -L1 -I{} rsync -uavh {} ${SERVER_FOLDER} --delete-excluded
}

#sync
echo "=== Done at `date`"
