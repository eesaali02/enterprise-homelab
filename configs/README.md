# Configuration exports

- `windows/`: GPO backups (`Backup-GPO`) and GPO HTML reports, RRAS settings exports
- `linux/`: BIND zone files and `named.conf`, Kea config, `chrony.conf`, Nginx site files, one folder per server
- `pfsense/`: configuration backups, **encrypted only**
- `wazuh/`: custom rules and agent group configuration

Commit a config each time it changes, with a message that says why. Never commit private keys or passwords.
