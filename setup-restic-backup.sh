#!/usr/bin/env bash

sudo cp ./restic-backup-remote.service ./restic-backup-remote.timer ./restic-backup.service ./restic-backup.timer /usr/lib/systemd/user

systemctl --user enable restic-backup.service
systemctl --user enable restic-backup.timer
systemctl --user enable restic-backup-remote.service
systemctl --user enable restic-backup-remote.timer

if [[ ! -f $HOME/restic-backup-files ]]; then
    ln -s $PWD/restic-backup-files $HOME/restic-backup-files
fi

if [[ ! -f $HOME/restic-excludes ]]; then
    ln -s $PWD/restic-excludes $HOME/restic-excludes
fi

