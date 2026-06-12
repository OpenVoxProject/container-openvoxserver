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

PATH=$PATH:/opt/puppetlabs/puppet/lib/ruby/vendor_gems/bin:/opt/puppetlabs/server/data/puppetserver/vendored-jruby-gems/bin/

pid=0

echoerr() { echo "$@" 1>&2; }

echoerr "Entrypoint PID $$"

# Generic execution function for custom handlers
# Usage: run_custom_handler [handler_name]
run_custom_handler() {
  local CUSTOM_HANDLER_ROOT_DIRECTORY=""
  local CUSTOM_HANDLER_DIRECTORY=""
  local -a DIR_LIST=("/docker-custom-entrypoint.d" "/container-custom-entrypoint.d")

  for CUSTOM_HANDLER_ROOT_DIRECTORY in "${DIR_LIST[@]}"; do
    if [ -d "${CUSTOM_HANDLER_ROOT_DIRECTORY}" ]; then
      if [[ "${CUSTOM_HANDLER_ROOT_DIRECTORY}" == "/docker-custom-entrypoint.d" ]]; then
        if [[ $# -eq 1 && "$1" == "pre-default" ]]; then
          echoerr "DEPRECATED: Use /container-custom-entrypoint.d/ instead of /docker-custom-entrypoint.d/"
        fi
      fi

      if [[ $# -eq 0 || "$1" == "" ]]; then
        CUSTOM_HANDLER_DIRECTORY=${CUSTOM_HANDLER_ROOT_DIRECTORY}
      else
        CUSTOM_HANDLER_DIRECTORY=${CUSTOM_HANDLER_ROOT_DIRECTORY}/$1
      fi

      if [ -d ${CUSTOM_HANDLER_DIRECTORY}/ ]; then
        find ${CUSTOM_HANDLER_DIRECTORY}/ -type f -name "*.sh" \
          -exec chmod +x {} \;
        sync
        for f in ${CUSTOM_HANDLER_DIRECTORY}/*.sh; do
          if [[ -f "$f" && -x $(realpath "$f") ]]; then
            echo "Running $f"
            "$f"
          fi
        done
      fi
    fi
  done
}

## Pre execution handler
pre_execution_handler() {
  run_custom_handler pre-default

  if [ -d /docker-entrypoint.d ]; then
    echoerr "DEPRECATED: Use /container-entrypoint.d/ instead of /docker-entrypoint.d/"
    for f in /docker-entrypoint.d/*.sh; do
      echo "Running $f"
      "$f"
    done
  fi

  for f in /container-entrypoint.d/*.sh; do
    echo "Running $f"
    "$f"
  done

  run_custom_handler
}

## Post startup handler
post_startup_handler() {
  run_custom_handler post-startup
}

## Post execution handler
post_execution_handler() {
  run_custom_handler post-execution
}

## Sigterm Handler
# shellcheck disable=SC2317 # function is called when the container receives a SIGTERM signal
sigterm_handler() {
  echoerr "Catching SIGTERM"
  if [ $pid -ne 0 ]; then
    echoerr "sigterm_handler for PID '${pid}' triggered"
    # the above if statement is important because it ensures
    # that the application has already started. without it you
    # could attempt cleanup steps if the application failed to
    # start, causing errors.
    run_custom_handler sigterm-handler
    kill -15 "$pid"
    wait "$pid"
    post_execution_handler
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

## Setup signal trap
# on callback execute the specified handler
trap sigterm_handler SIGTERM

## Initialization
pre_execution_handler

## Start Process
echoerr "Starting Puppetserver"
# run process in background and record PID
/opt/puppetlabs/bin/puppetserver "$@" &
pid="$!"

## Post Startup
post_startup_handler

## Wait forever until app dies
wait "$pid"
return_code="$?"

## Cleanup
post_execution_handler
# echo the return code of the application
exit $return_code
