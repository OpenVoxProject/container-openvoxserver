#! /bin/sh

set -e

### Print configuration for troubleshooting
echo "System configuration values:"
# shellcheck disable=SC2039 # Docker injects $HOSTNAME
echo "* HOSTNAME: '${HOSTNAME}'"
echo "* hostname -f: '$(hostname -f)'"

ssl_dir=$(puppet config print ssldir)

if [ -n "${CERTNAME}" ]; then
  echo "* CERTNAME: '${CERTNAME}'"
  certname=${CERTNAME}.pem
else
  echo "* CERTNAME: unset, try to use the oldest certificate in the certs directory, because this might be the one that was used initially."
  if [ ! -d "${ssl_dir}/certs" ]; then
    certname="Not-Found"
    echo "WARNING: No certificates directory found in ${ssl_dir}!"
  else
    certname=$(cd "${ssl_dir}/certs" && find * -type f -name '*.pem' ! -name ca.pem -print0 | xargs -0 ls -1tr | head -n 1)
    if [ -z "${certname}" ]; then
      echo "WARNING: No certificates found in ${ssl_dir}/certs! Please set CERTNAME!"
    fi
  fi
fi

echo "* OPENVOXSERVER_PORT: '${OPENVOXSERVER_PORT:-8140}'"
echo "* Certname: '${certname}'"
echo "* DNS_ALT_NAMES: '${DNS_ALT_NAMES}'"
echo "* SSLDIR: '${ssl_dir}'"

altnames="-certopt no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux"

if [ -f "${ssl_dir}/certs/ca.pem" ]; then
  echo "CA Certificate:"
  # shellcheck disable=SC2086 # $altnames shouldn't be quoted
  openssl x509 -subject -issuer -text -noout -in "${ssl_dir}/certs/ca.pem" $altnames
fi

if [ -n "${certname}" ]; then
  if [ -f "${ssl_dir}/certs/${certname}" ]; then
    echo "Certificate ${certname}:"
    # shellcheck disable=SC2086 # $altnames shouldn't be quoted
    openssl x509 -subject -issuer -text -noout -in "${ssl_dir}/certs/${certname}" $altnames
  else
    echo "WARNING: Certificate ${certname} not found in ${ssl_dir}/certs!"
  fi
fi
