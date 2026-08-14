# Migrations

## Coming from a fixed UID release 

The container runs with **group 0** and works under **any UID**. File access is granted exclusively through group 0, and the UID of files on mounted volumes does not matter. There is no `puppet` service account in the image anymore. 

For existing volumes, run once:

```bash
chgrp -R 0 [PATH TO THE VOLUME]
chmod -R g+rwX [PATH TO THE VOLUME]
```

On Kubernetes/OpenShift using `fsGroup: 0` in the pod securityContext can be used to achieve the same.
