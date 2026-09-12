#!/bin/bash
# Configure GDM auto-login for the first non-root user

USER=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1; exit}' /etc/passwd)
if [ -z "$USER" ]; then
    echo "No non-root user found; skipping auto-login"
    exit 0
fi

# GDM custom.conf auto-login
mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf <<EOF
[daemon]
AutomaticLogin=$USER
AutomaticLoginEnable=True
EOF

# dconf GDM auto-login (belt-and-suspenders)
mkdir -p /etc/dconf/db/gdm.d
cat > /etc/dconf/db/gdm.d/01-autologin <<EOF
[org/gnome/login-screen]
auto-login-user='$USER'
auto-login-enabled=true
EOF
dconf update

touch /etc/.yutyrannus-autologin-configured