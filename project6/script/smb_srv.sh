#!/usr/bin/env bash
#apt-get upgrade
#apt install -y samba

smbuser="demoUser"
smbgroup="demoGroup"

useradd -M -s $(which nologin) "$smbuser"
echo "$smbuser:password" | chpasswd

(echo password; echo password) | smbpasswd -a "$smbuser"

cat<<EOT >>/etc/samba/smb.conf
[guest]
path = /home/samba/guest/
read only = yes
guest ok = yes
[demo]
path = /home/samba/demo/
read only = no
guest ok = no
force create mode = 0660
force directory mode = 2770
force user = "$smbuser"
force group = "$smbgroup"
EOT

smbpasswd -e "$smbuser"
groupadd "$smbgroup"
usermod -G "$smbgroup" "$smbuser"
mkdir -p /home/$smbuser/guest/
mkdir -p /home/$smbuser/demo/
chgrp -R "$smbgroup" /home/$smbuser/guest/
chgrp -R "$smbgroup" /home/$smbuser/demo/
chmod 2775 /home/$smbuser/guest/
chmod 2770 /home/$smbuser/demo/

service smbd restart
