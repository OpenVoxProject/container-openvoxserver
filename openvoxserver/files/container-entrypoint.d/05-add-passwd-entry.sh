#!/bin/bash

# OpenSSH requires a passwd entry for the running UID.
if ! getent passwd "$(id -u)" >/dev/null 2>&1; then
  if [ -w /etc/passwd ]; then
    echo "puppet:x:$(id -u):0:puppet container user:${HOME}:/bin/sh" >> /etc/passwd
  else
    echo "WARNING: UID $(id -u) has no passwd entry and /etc/passwd is not writable; ssh will fail" >&2
  fi
fi
