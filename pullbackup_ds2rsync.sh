#!/bin/sh

JOBID=$1
VPNCONFIGPATH="/etc/openvpn/myhost.ovpn"
VPNSECRETPATH="/etc/openvpn/.secret"
REMOTEUSER="myuser"
REMOTEHOST="192.168.179.1"

# VPN-Verbindung aufbauen
echo VPN-Verbindung wird aufgebaut...
sudo openvpn --config "$VPNCONFIGPATH" --auth-user-pass "$VPNSECRETPATH" --daemon

# Warten bis die VPN-Verbindung steht
echo Warte 30 Sekunden bis die VPN-Verbindung steht
sleep 30

echo Backup Job $JOBID wird gestartet...

# SSH auf den zu sichernden Server und Starten des Backup Jobs. Die JOBID wird als erster Parameter bei Script-Ausführung erwartet.
# Die Konfiguration der Hyper Backup Jobs und die Job-ID findet man in
# /var/packages/HyperBackup/etc/synobackup.conf (früher: /usr/syno/etc/synobackup.conf)
# Die << Pfeile weisen das Script an, alle Inhalte bis zum zweiten "EOT" als ein Kommando an den Remote Host zu senden (Heredoc oder Here Doc)
# Dabei gibt es Quoted oder unquoted Heredocs. Wird das Heredoc unquoted (also << EOT) eröffnet, werden die Variablen bereits lokal ausgewertet und gefüllt an den Remote Host gesendet, was teilweise unerwünscht sein kann.
# Wenn bei unquoted Heredocs einzelne Variablen nicht zuvor ausgewertet werden sollen, muss man diese Variablen mit \ escapen, also \$VARIABLE, dann werden sie wieder erst vom Remote Host gefüllt.
# Bei quoted Heredocs (also << 'EOT') wird der gesamte String an den Remote Host gesendet und erst von diesem ausgewertet.
ssh $REMOTEUSER@$REMOTEHOST /bin/bash << EOT
/var/packages/HyperBackup/target/bin/dsmbackup --backup $JOBID
echo sleep 60 vor While Schleife
sleep 60

# Prüfe alle 60 Sekunden, ob der Backup-Job noch läuft. Wenn er nicht mehr läuft, beende die Verbindung.
while [ "\$(/bin/pidof img_backup)" -o  "\$(/bin/pidof dsmbackup)" -o  "\$(/bin/pidof synoimgbktool)" -o  "\$(/bin/pidof synolocalbkp)" -o  "\$(/bin/pidof synonetbkp)" -o  "\$(/bin/pidof updatebackup)" ]
do
 echo While Schleife
 echo Host in Schleife: \$HOSTNAME
 echo sleep 60
 sleep 60
done

echo While Schleife beendet

# Hier endet das Kommando für den Remote Host
EOT

# Wir befinden uns wieder auf dem localhost, von hier aus wird der VPN Client beendet (schöner geht's wohl leider nicht)
sudo killall -SIGINT openvpn

exit 0
