# Migrations

## V8.12.0 -> V8.13.0

UID is changed from 1001 on alpine and 999 on ubuntu to 64604.
If you already deployed the containers with mounted volumes, you HAVE to change the ownership of these volumes and the files underneath.

```bash
chown -R 64604:0 /path/to/ca_mountpoint
chown -R 64604:0 /path/to/ssl_mountpoint
```
