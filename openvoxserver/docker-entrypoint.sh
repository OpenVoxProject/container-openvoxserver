#!/bin/bash
# bash is required to pass ENV vars with dots as sh cannot

set -o errexit  # exit on any command failure; use `whatever || true` to accept failures
                # use `if something; then` instead of `something; if [ $? -eq 0 ]; then`
                # use `rv=0; something || rv=$?` if you really need the exact exit code
set -o pipefail # pipes fail when any command fails, not just the last one. Use: ( whatever || true ) | somethingelse
set -o nounset  # exit on use of undeclared var, use `${possibly_undefined-}` to substitute the empty string in that case
                # You can assign default values like this:
                # `: ${possibly_undefined=default}`
                # `: ${possibly_undefined_or_empty:=default}` will also replace an empty (but declared) value
# set -o xtrace

echoerr() { echo "$@" 1>&2; }

echoerr "DEPRECATED: Use /container-entrypoint.sh instead of /docker-entrypoint.sh"
exec ./container-entrypoint.sh "$@"
