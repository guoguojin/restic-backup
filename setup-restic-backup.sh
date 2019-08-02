#!/usr/bin/env bash

sudo cp ./restic-backup-remote.service ./restic-back-remote.timer ./restic-backup.service ./restic-backup.timer /usr/lib/systemd/user
systemctl --user enable restic-backup.service
systemctl --user enable restic-backup.timer
systemctl --user enable restic-backup-remote.service
systemctl --user enable restic-backup-remote.timer
