# ds_hyperbackup2remote
Script to initiate a VPN connection, start a Hyper Backup job from the remote Hyper Backup target (for use behind a firewall e. g.) and disconnect the VPN connection after completing the backup job. My use case for this is that I have my backup target DiskStation standing in a remote site behind a firewall. Because I don't have the option to establish a VPN connection from external to this DS, I created a way to initiate the backup FROM the target machine.

This script ist developed and tested with Synology DiskStation Manager (DSM) 6.2.2.

Prerequisites:
You will need to configure a working VPN connection AND a public key authenticated SSH connection from your target DiskStation (which is also your Hyper Backup target).

Short description (in German, because it's my native language :-) and I needed to write it quickly, English translation will follow later):

- Hyper Backup Job anlegen
- VPN-Verbindung anlegen
- VPN-Verbindung testen (wichtig für Last Connection File)
- im Script /volume1/script/pullbackupvpn.sh folgende Parameter setzen:
-- VPN Connection --> Parameter conf_id, conf_name und proto aus /usr/syno/etc/synovpnclient/vpnc_last_connect
-- sudo /usr/syno/bin/synovpnc connect --id=o<10stelligeID>
-- Backup Job --> nur Nummer aus /usr/syno/etc/synobackup.conf --> [task_]
- id_rsa und known_hosts kopieren nach /root/.ssh
- chmod 600 id_rsa

- Im Task Scheduler neuen Job anlegen
-- Create --> Scheduled Task --> User-defined script
-- General: User: root
-- Task Settings: Run command
-- bash /volume1/script/backup2remote/pullbackupvpn.sh

- Fehlersuche:
-- tail -n 100 /var/log/messages

- Verbose Log im OpenVPN Config File aktivieren (erweitert die Ausgabe in /var/log/messages):
-- sudo vi /usr/syno/etc/synovpnclient/openvpn/client_o<10stelligeID>
--> verb 4 einfügen bzw. reaktivieren

- Job als root testen
-- sudo -i
-- /volume1/script/backup2remote/pullbackupvpn.sh
