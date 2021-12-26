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
  # Set up automated backup locally and to Backblaze B2 using restic on Arch Linux
  
  1. Use your package manager to install restic from the Community repository or the AUR
  2. Follow the instructions for creating a repo [here.](https://restic.readthedocs.io/en/latest/) Create both a local and a Backblaze repo.
  3. Create a file containing the repo's password in a secure location and set the appropriate permissions
  4. If you want to exclude certain directories and files, you can create an exclude file using the instructions [here.](https://restic.readthedocs.io/en/latest/040_backup.html#including-and-excluding-files)
  5. Create a script for running the backup with restic. In the script you will need to set the environment parameters for the B2_ACCOUNT_ID and B2_ACCOUNT_KEY required to access Backblaze B2.
  
      ```bash
      #!/usr/bin/env bash
  
      export B2_ACCOUNT_ID="YOUR_ID"
      export B2_ACCOUNT_KEY="YOUR_KEY"
      export RESTIC_PASSWORD_FILE=/path/to/your/password
  
      restic -r /your/backup/location backup --verbose /folder/to/backup --exclude-file=/path/to/your/exclude-file
      restic -r b2:your-b2-bucket:/your/b2/backup-folder backup --verbose /folder/to/backup --exclude-file=/path/to/your/exclude-file
      ```
  6. Arch uses the systemd timer schedules as an alternative to cron. In order to automate the backups, we need to set up a user systemd service and a systemd timer and enable both. The service will execute the script we created in the step above to perform the backups, but only as your user rather than a system-wide service.
  
  7. Create a service file in /usr/lib/systemd/user. We will call this service file restic-backup.service:
  
      ```bash
      [Unit]
      Description=Backup locally and to Backblaze B2 using Restic
  
      [Service]
      ExecStart=/path/to/your/backup-script
  
      [Install]
      WantedBy=default.target
      ```
  8. Create a timer file in /user/lib/systemd/user. We will call this service file restic-backup.timer:
  
      ```bash
      [Unit]
      Description=Run restic backup locally and to Backblaze B2 every hour
  
      [Timer]
      # Time to wait after booting before we run first time
      OnBootSec=1h
      # If you want to run it every hour after the job has started
      # OnUnitActiveSec=1h
      # If you want to run on the hour, every hour
      OnCalendar=00/1:00
      Unit=restic-backup.service        # This is the systemd service you created to do the backups
  
      [Install]
      WantedBy=timers.target
      ```
  
  9.  Test your service to make sure everything works properly, the watch command allows us to monitor the status of the service without having to issue the systemctl status command repeatedly:
  
      ```bash
      systemctl --user start restic-backup.service
      watch systemctl --user status restic-backup.service
      ``` 
  10. If everything is working correct, you can to start and enable the timer:
  
      ```bash
      systemctl --user start restic-backup.timer
      systemctl --user enable restic-backup.timer
      ```
  11. You should cleanup your snapshots periodically to save disk space. This is done with ```restic forget``` and ```restic prune```. The ```forget``` command removes the snapshot, but doesn't delete the underlying data. To clean the underlying data you must use the ```prune``` command. References to how restic selects which snapshots to forget can be found [here](https://restic.net/blog/2016-08-22/removing-snapshots). To do this, create another script:
  
      ```bash
      #!/usr/bin/env bash
  
      export B2_ACCOUNT_ID="YOUR_ID"
      export B2_ACCOUNT_KEY="YOUR_KEY"
      export RESTIC_PASSWORD_FILE=/path/to/your/password
  
      restic -r /your/backup/location forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12
      restic -r b2:your-b2-bucket:/your/b2/backup-folder forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12
      restic -r /your/backup/location prune
      restic -r b2:your-b2-bucket:/your/b2/backup-folder forget
      ```
  
  12. Now you can create another service and timer file using the instructions above and create an appropriate schedule for cleaning up your backups.
  
      ```bash
      [Unit]
      Description=Clean up restic backups from local cache and to Backblaze B2 every Sunday
  
      [Timer]
      # Time to wait after booting before we run first time
      OnBootSec=1h
      # Run every Sunday at 1AM
      OnCalendar=Sun *-*-* 01:00:00
      # In the event the job wasn't run at the last scheduled time, i.e. the machine was off etc.
      Persistent=true
      Unit=restic-cleanup.service
  
      [Install]
      WantedBy=timers.target
      ```
  
