# Migrations

## Image tags: build numbers replace `-main` and `-v<container.version>`

From 21 November 2026, images built from the `main` branch are tagged `<openvox.version>-<build>`
(for example `8.18.0-1` and `8.18.0-1-alpine`) instead of `<openvox.version>-main`.
Git tags of this repository no longer publish `<openvox.version>-v<container.version>` images.
See the [version schema](README.md#version-schema) for how build numbers are assigned.

The old tags still exist, but they are no longer updated, so an image pinned to one of them stops receiving fixes.
Pulling them does not fail or warn.
Switch to one of the current tags:

| Old tag | Use instead |
| --- | --- |
| `<openvox.version>-main` | `<openvox.version>` to follow the latest build, or `<openvox.version>-<build>` to pin one |
| `<openvox.version>-main-alpine` | `<openvox.version>-alpine`, or `<openvox.version>-<build>-alpine` |
| `<openvox.version>-v<container.version>` | `<openvox.version>-<build>` |
| `<openvox.version>-v<container.version>-alpine` | `<openvox.version>-<build>-alpine` |

The first build-numbered images are `8.18.0-0` and `9.2.0-0`.

## V8.12.0 -> V8.13.0

UID is changed from 1001 on alpine and 999 on ubuntu to 64604.
If you already deployed the containers with mounted volumes, you HAVE to change the ownership of these volumes and the files underneath.

```bash
chown -R 64604:0 /path/to/ca_mountpoint
chown -R 64604:0 /path/to/ssl_mountpoint
```
