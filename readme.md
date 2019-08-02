# Restic backup service and timer configuration

To use, copy or link these files to:

/usr/lib/systemd/user

then enable them as user services with systemd:

```bash
systemctl --user enable restic-backup.service
systemctl --user enable restic-backup.timer
systemctl --user enable restic-backup-remote.service
systemctl --user enable restic-backup-remote.timer
```
