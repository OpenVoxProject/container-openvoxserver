# OpenVox Server container

[![CI](https://github.com/openvoxproject/container-openvoxserver/actions/workflows/ci.yaml/badge.svg)](https://github.com/openvoxproject/container-openvoxserver/actions/workflows/ci.yaml)
[![License](https://img.shields.io/github/license/openvoxproject/container-openvoxserver.svg)](https://github.com/openvoxproject/container-openvoxserver/blob/main/LICENSE)
[![Sponsored by betadots GmbH](https://img.shields.io/badge/Sponsored%20by-betadots%20GmbH-blue.svg)](https://www.betadots.de)

---

- [OpenVox Server container](#openvox-server-container)
  - [Informations](#informations)
    - [End of Life for OpenVox Server 7](#end-of-life-for-openvox-server-7)
  - [Note about environment caching](#note-about-environment-caching)
  - [Version schema](#version-schema)
  - [Configuration](#configuration)
  - [Initialization Scripts](#initialization-scripts)
  - [Persistence](#persistence)
  - [How to Release the container](#how-to-release-the-container)
  - [How to contribute](#how-to-contribute)

---

This project hosts the Containerfile and the required scripts to build a OpenVox Server container image.

You can run a copy of Puppet Server with the following Docker command:

```bash
podman run --name openvox --hostname openvox ghcr.io/openvoxproject/openvoxserver:8.8.0-latest
```

Although it is not strictly necessary to name the container `openvox`, this is
useful when working with the other OpenVox images, as they will look for a server
on that hostname by default.

If you would like to start the OpenVox Server with your own Puppet code, you can
mount your own directory at `/etc/puppetlabs/code`:

```shell
podman run --name openvox --hostname openvox -v ./code:/etc/puppetlabs/code ghcr.io/openvoxproject/openvoxserver:8.8.0-latest
```

For compose file see: [CRAFTY](https://github.com/voxpupuli/crafty/tree/main/openvox/oss)

## Informations

### End of Life for OpenVox Server 7

⚠️ On February 28, 2025, OpenVox/Puppet 7 entered its end-of-life phase.
Consequently, no new OpenVox Server 7 releases will be build.
Existing versions will be retained for continued access.

## Note about environment caching

⚠️ The OpenVox Server has [the environment caching](https://www.puppet.com/docs/puppet/8/server/admin-api/v1/environment-cache.html) enabled by default.
You should explicitly call the API endpoint to clear the cache when a new environment is deployed.
See the `curl` example below.

```bash
curl -i --cert $(puppet config print hostcert) \
--key $(puppet config print hostprivkey) \
--cacert $(puppet config print cacert) \
-X DELETE \
https://$(puppet config print server):8140/puppet-admin-api/v1/environment-cache?environment=production
```

Another option is to disable the environment caching by setting the `OPENVOXSERVER_ENVIRONMENT_TIMEOUT` environment variable to zero (`0`).

## Version schema

The version schema has the following layout:

```text
<openvox.major>.<openvox.minor>.<openvox.patch>-v<container.major>.<container.minor>.<container.patch>
```

Example usage:

```shell
podman run --name openvox --hostname openvox -v ./code:/etc/puppetlabs/code/ ghcr.io/openvoxproject/openvoxserver:8.8.0-v1.0.0
```

| Name            | Description                                                                               |
| --------------- | ----------------------------------------------------------------------------------------- |
| openvox.major   | Describes the contained major OpenVox version                                             |
| openvox.minor   | Describes the contained minor OpenVox version                                             |
| openvox.patch   | Describes the contained patchlevel OpenVox version                                        |
| container.major | Describes the major version of the base container (Ubunutu 24.04) or incompatible changes |
| container.minor | Describes new features or refactoring with backward compatibility                         |
| container.patch | Describes if minor changes or bugfixes have been implemented                              |

## Configuration

The following environment variables are supported:

<!-- markdownlint-disable table-column-style -->
<!-- markdownlint-disable line-length -->
| Name                                        | Usage / Default |
|---------------------------------------------| --------------- |
| __AUTOSIGN__                                | Whether or not to enable autosigning on the openvoxserver instance. Valid values are `true`, `false`, and `/path/to/autosign.conf`.<br><br>Defaults to `true`. |
| __CA_ALLOW_SUBJECT_ALT_NAMES__              | Whether or not SSL certificates containing Subject Alternative Names should be signed by the CA. Does nothing unless `CA_ENABLED=true`.<br><br>Defaults to `false` |
| __CA_ENABLED__                              | Whether or not this openvoxserver instance has a running CA (Certificate Authority)<br><br>Defaults to `true` |
| __CA_HOSTNAME__                             | The DNS hostname for the openvoxserver running the CA. Does nothing unless `CA_ENABLED=false`<br><br>Defaults to `puppet` |
| __CA_PORT__                                 | The listening port of the CA. Does nothing unless `CA_ENABLED=false`<br><br>Defaults to `8140` |
| __CA_TTL__                                  | CA expire date (in seconds or with suffix `s`, `m`, `h`, `d`, `y`)<br><br>Defaults to `157680000` |
| __CERTNAME__                                | The DNS name used on the servers SSL certificate - sets the `certname` in puppet.conf<br><br>Defaults to unset. |
| __CSR_ATTRIBUTES__                          | Provide a JSON string of the csr_attributes.yaml content. e.g. `CSR_ATTRIBUTES='{"custom_attributes": { "challengePassword": "foobar" }, "extension_requests": { "pp_project": "foo" } }'`<br><br> Defaults to empty JSON object `{}`<br> Please note that within a compose file, you must provide all environment variables as Hash and not as Array!<br> environment:<br> `CSR_ATTRIBUTES: '{"extension_request": {...}}'` |
| __DNS_ALT_NAMES__                           | Additional DNS names to add to the servers SSL certificate<br>__Note__ only effective on initial run when certificates are generated |
| __ENVIRONMENTPATH__                         | Set an environmentpath<br><br> Defaults to `/etc/puppetlabs/code/environments` |
| __HIERACONFIG__                             | Set a hiera_config entry in puppet.conf file<br><br> Defaults to `$confdir/hiera.yaml` |
| __INTERMEDIATE_CA__                         | Allows to import an existing intermediate CA. Needs `INTERMEDIATE_CA_BUNDLE`, `INTERMEDIATE_CA_CHAIN` and `INTERMEDIATE_CA_KEY`. See [Puppet Intermediat CA](https://www.puppet.com/docs/puppet/latest/server/intermediate_ca.html) |
| __INTERMEDIATE_CA_BUNDLE__                  | File path and name to the complete CA bundle (signing CA + Intermediate CA) |
| __INTERMEDIATE_CA_KEY__                     | File path and name to the private CA key |
| __INTERMEDIATE_CRL_CHAIN__                  | File path and name to the complete CA CRL chain |
| __OPENVOX_REPORTS__                         | Sets `reports` in puppet.conf<br><br>Defaults to `puppetdb` |
| __OPENVOX_STORECONFIGS__                    | Sets `storeconfigs` in puppet.conf<br><br>Defaults to `true` |
| __OPENVOX_STORECONFIGS_BACKEND__            | Sets `storeconfigs_backend` in puppet.conf<br><br>Defaults to `puppetdb` |
| __OPENVOXDB_SERVER_URLS__                   | The URL of the OpenVoxDB servers. This is used to connect to the OpenVoxDB server. <br><br> Defaults to `https://openvoxdb:8081`<br> Please note that within a compose file, you must provide all environment variables as Hash and not as Array!<br> environment:<br> `OPENVOXDB_SERVER_URLS: 'https://openvoxdb:8081'` |
| __OPENVOXSERVER_ENABLE_ENV_CACHE_DEL_API__  | Enable the puppet admin api endpoint via certificates to allow clearing environment caches<br><br> Defaults to `true` |
| __OPENVOXSERVER_ENVIRONMENT_TIMEOUT__       | Configure the environment timeout<br><br> Defaults to `unlimited` |
| __OPENVOXSERVER_GRAPHITE_EXPORTER_ENABLED__ | Activate the graphite exporter. Also needs __OPENVOXSERVER_GRAPHITE_HOST__ and __OPENVOXSERVER_GRAPHITE_PORT__<br><br>  Defaults to `false` |
| __OPENVOXSERVER_GRAPHITE_HOST__             | Only used if __OPENVOXSERVER_GRAPHITE_EXPORTER_ENABLED__ is set to `true`. FQDN or Hostname of the graphite server where puppet should push metrics to. <br><br> Defaults to `exporter` |
| __OPENVOXSERVER_GRAPHITE_PORT__             | Only used if __OPENVOXSERVER_GRAPHITE_EXPORTER_ENABLED__ is set to `true`. Port of the graphite server where puppet should push metrics to. <br><br> Default to `9109` |
| __OPENVOXSERVER_HOSTNAME__                  | The DNS name used on the servers SSL certificate - sets the `server` in puppet.conf<br><br>Defaults to unset. |
| __OPENVOXSERVER_JAVA_ARGS__                 | Arguments passed directly to the JVM when starting the service<br><br>Defaults to `-Xms1024m -Xmx1024m` |
| __OPENVOXSERVER_MAX_ACTIVE_INSTANCES__      | The maximum number of JRuby instances allowed<br><br>Defaults to `1` |
| __OPENVOXSERVER_MAX_REQUESTS_PER_INSTANCE__ | The maximum HTTP requests a JRuby instance will handle in its lifetime (disable instance flushing)<br><br>Defaults to `0` |
| __OPENVOXSERVER_PORT__                      | The port of the openvoxserver<br><br>Defaults to `8140` |
| __USE_OPENVOXDB__                           | Whether to connect to puppetdb <br>Sets `OPENVOX_REPORTS` to `log` and `OPENVOX_STORECONFIGS` to `false` if `OPENVOX_STORECONFIGS_BACKEND` is `puppetdb`. <br><br>Defaults to `true` |
<!-- markdownlint-enable line-length -->
<!-- markdownlint-enable table-column-style -->

## Initialization Scripts

If you would like to do additional initialization, add a directory called `/container-custom-entrypoint.d/` and fill it with `.sh` scripts.

You can also create sub-directories in `/container-custom-entrypoint.d/` for scripts that have to run at different stages.

- `/container-custom-entrypoint.d/pre-default/` - scripts that run before the default entrypoints scripts.
- `/container-custom-entrypoint.d/` - scripts that run after the default entrypoint scripts, but before the openvoxserver service is started.
- `/container-custom-entrypoint.d/post-startup/` - scripts that run after the openvoxserver service is started.
- `/container-custom-entrypoint.d/sigterm-handler/` - scripts that run when the container receives a SIGTERM signal.
- `/container-custom-entrypoint.d/post-execution/` - scripts that run after the openvoxserver service has stopped.

## Persistence

If you plan to use the in-server CA, restarting the container can cause the server's keys and certificates to change, causing agents and the server to stop trusting each other.
To prevent this, you can persist the default cadir, `/etc/puppetlabs/puppetserver/ca`.
For example:

```shell
podman run -v $PWD/ca-ssl:/etc/puppetlabs/puppetserver/ca ghcr.io/openvoxproject/openvoxserver:8.6.1-latest
```

or in compose:

```yaml
services:
  puppet:
    image: ghcr.io/openvoxproject/openvoxserver:8.8.0-latest
    # ...
    volumes:
      - ./ca-ssl:/etc/puppetlabs/puppetserver/ca
```

## How to Release the container

[see here](RELEASE.md)

## How to contribute

[see here](https://github.com/voxpupuli/crafty/blob/main/CONTRIBUTING.md)
