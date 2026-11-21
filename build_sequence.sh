#!/bin/bash
#
# Print the build sequence number for the next published image of each
# OpenVox Server version, as a compact JSON object, e.g. {"8.18.0":2,"9.2.0":0}.
#
# The number is one more than the highest existing <version>-<n> or
# <version>-<n>-alpine tag in the registry, or 0 if there is none.
#
# Usage: build_sequence.sh [--tags FILE] [VERSION...]
#
#   --tags FILE  read the tag list (the JSON printed by "skopeo list-tags")
#                from FILE instead of querying the registry
#   VERSION...   server versions to number; defaults to every server_version
#                in build_versions.yaml
#
# Fails, rather than falling back to 0, if the tag list cannot be read.

set -euo pipefail

image=${IMAGE:-ghcr.io/openvoxproject/openvoxserver}
tags_file=

if [ "${1:-}" == "--tags" ]; then
  tags_file=${2:?--tags needs a file argument}
  shift 2
fi

if [ $# -eq 0 ]; then
  mapfile -t versions < <(yq -r '.include[].server_version' build_versions.yaml)
  set -- "${versions[@]}"
fi

if [ $# -eq 0 ]; then
  echo "build_sequence.sh: no server versions to number" >&2
  exit 1
fi

if [ -n "$tags_file" ]; then
  tags_json=$(cat "$tags_file")
else
  tags_json=$(skopeo list-tags "docker://$image")
fi

jq -cn --argjson listing "$tags_json" '
  if ($listing.Tags | type) != "array" then
    error("tag list has no .Tags array")
  else
    $listing.Tags
  end
  | . as $tags
  | [
      $ARGS.positional[] as $version
      | {
          ($version): (
            [
              $tags[]
              | select(startswith($version + "-"))
              | ltrimstr($version + "-")
              | capture("^(?<n>[0-9]+)(-alpine)?$")
              | .n
              | tonumber
            ]
            | (max // -1) + 1
          )
        }
    ]
  | add
' --args "$@"
