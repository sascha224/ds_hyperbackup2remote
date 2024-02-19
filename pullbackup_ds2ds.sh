# VPN Parameterdatei für den Verbindungsaufbau konfigurieren. Parameter findet man unter
# /usr/syno/etc/synovpnclient/openvpn/ovpnclient.conf
CONNFILE=/usr/syno/etc/synovpnclient/vpnc_connecting
sudo sh -c "echo conf_id=o1234567890 > /usr/syno/etc/synovpnclient/vpnc_connecting"
sudo sh -c "echo conf_name=ds1_home >> /usr/syno/etc/synovpnclient/vpnc_connecting"
sudo sh -c "echo proto=openvpn >> /usr/syno/etc/synovpnclient/vpnc_connecting"

# VPN-Verbindung mit der eben erzeugten Datei aufbauen
echo VPN-Verbindung wird aufgebaut...
sudo /usr/syno/bin/synovpnc connect --id=o1234567890

# Warten bis die VPN-Verbindung steht
echo Warte 60 Sekunden bis die VPN-Verbindung steht
sleep 60

# SSH auf den zu sichernden Server und Starten des Backup Jobs.
# Die Konfiguration der Hyper Backup Jobs und die Job-ID findet man in
# /var/packages/HyperBackup/etc/synobackup.conf (alt: /usr/syno/etc/synobackup.conf)
# Die << Pfeile weisen das Script an, alle Inhalte bis zum zweiten "EOT" als ein Kommando an den Remote Host zu senden
echo Backup Job wird gestartet...
ssh backupuser@192.168.179.1 /bin/bash << 'EOT'
/var/packages/HyperBackup/target/bin/dsmbackup --backup 19
#echo Host nach SSH: $HOSTNAME
echo sleep 60 vor While Schleife
sleep 60

# Prüfe alle 60 Sekunden, ob der Backup-Job noch läuft. Wenn er nicht mehr läuft, beende die Verbindung.
while [ "$(/bin/pidof img_backup)" -o  "$(/bin/pidof dsmbackup)" -o  "$(/bin/pidof synoimgbktool)" -o  "$(/bin/pidof synolocalbkp)" -o  "$(/bin/pidof synonetbkp)" -o  "$(/bin/pidof updatebackup)" ]
do
 echo While Schleife
 echo Host in Schleife: $HOSTNAME
 echo sleep 60
 sleep 60
done

echo While Schleife beendet

# Hier endet das Kommando für den Remote Host
EOT

# Wir befinden uns wieder auf dem localhost, von hier aus wird der VPN Client beendet
sudo /usr/syno/bin/synovpnc kill_client

exit 0
