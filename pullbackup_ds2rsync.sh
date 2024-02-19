# VPN-Verbindung aufbauen
echo VPN-Verbindung wird aufgebaut...
sudo openvpn --config "/etc/openvpn/ds1.ovpn" --auth-user-pass "/etc/openvpn/.secret" --daemon

# Warten bis die VPN-Verbindung steht
echo Warte 30 Sekunden bis die VPN-Verbindung steht
sleep 30

# SSH auf den zu sichernden Server und Starten des Backup Jobs.
# Die Konfiguration der Hyper Backup Jobs und die Job-ID findet man in
# /var/packages/HyperBackup/etc/synobackup.conf (alt: /usr/syno/etc/synobackup.conf)
# Die << Pfeile weisen das Script an, alle Inhalte bis zum zweiten "EOT" als ein Kommando an den Remote Host zu senden
echo Backup Job wird gestartet...
ssh hollynator@192.168.179.1 /bin/bash << 'EOT'
/var/packages/HyperBackup/target/bin/dsmbackup --backup 29
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

# Wir befinden uns wieder auf dem localhost, von hier aus wird der VPN Client beendet (schöner geht's wohl leider nicht)
sudo killall -SIGINT openvpn

exit 0
