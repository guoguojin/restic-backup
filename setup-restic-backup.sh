#!/usr/bin/env bash

sudo cp ./restic-backup-remote.service ./restic-back-remote.timer ./restic-backup.service ./restic-backup.timer /usr/lib/systemd/user
systemd --user enable restic-backup.service
systemd --user enable restic-backup.timer
systemd --user enable restic-backup-remote.service
systemd --user enable restic-backup-remote.timer
