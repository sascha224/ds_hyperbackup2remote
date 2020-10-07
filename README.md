# ds_hyperbackup2remote
Script to initiate a VPN connection, start a Hyper Backup job from the remote Hyper Backup target (for use behind a firewall e. g.) and disconnect the VPN connection after completing the backup job. My use case for this is that I have my backup target DiskStation standing in a remote site behind a firewall. Because I don't have the option to establish a VPN connection from external to this DS, I created a way to initiate the backup FROM the target machine.

For getting this working, you have to configure the certificate-based authentication from backup-target DS to the primary DS first.

This script ist developed and tested with Synology DiskStation Manager (DSM) 6.2.2.
