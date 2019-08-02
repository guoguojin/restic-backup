# Restic backup service and timer configuration

To use, copy or link these files to:

/usr/lib/systemd/user

then enable them as user services with systemd:

```bash
systemd --user enable restic-backup.service
systemd --user enable restic-backup.timer
systemd --user enable restic-backup-remote.service
systemd --user enable restic-backup-remote.timer
```
