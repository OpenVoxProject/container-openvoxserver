#!/bin/bash

yq -o=json build_platforms.yaml > build_platforms.json
yq -o=json build_versions.yaml > build_versions.json

if [ "$1" == "build" ]; then
  jq -rc --slurp '{ include: [ .[1].include[] as $i | .[0].platforms[] as $p | $i + {"platform": $p.platform, "runner": $p.runner} ] }' build_platforms.json build_versions.json
fi

if [ "$1" == "tag" ]; then
    jq -cr '.include |= map({ release: .release, server_version: .server_version, db_version: .db_version })' build_versions.json
fi

rm build_platforms.json
rm build_versions.json
