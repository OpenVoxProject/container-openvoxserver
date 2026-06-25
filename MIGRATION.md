# Migrations

## V8.12.0 -> V8.13.0

UID is changed from 1001 on alpine and 999 on ubuntu to 64604.
If you already deployed the containers with mounted volume, you NEED to change the ownershop of these volumes and the files underneath.

```bash
chown -R 64604:64604 [PATH TO THE VOLUME]
```
