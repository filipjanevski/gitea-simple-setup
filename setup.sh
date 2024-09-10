#!/bin/bash

# Set up variable
export GITEA_VERSION=1.22.2
export DOMAIN=git.example.com

# Install dependencies
apt install gnupg2 git unzip nginx certbot python3-certbot-nginx -y

# Add git user
adduser --system --group --disabled-password --shell /bin/bash --home /home/git --gecos 'Git Version Control' git

# Fetch and set up gitea binary
wget https://dl.gitea.io/gitea/$GITEA_VERSION/gitea-$GITEA_VERSION-linux-amd64
cp gitea-$GITEA_VERSION-linux-amd64 /usr/bin/gitea && chmod 755 /usr/bin/gitea
mkdir -p /etc/gitea /var/lib/gitea/{custom,data,indexers,public,log}
chown git:git /etc/gitea /var/lib/gitea/{custom,data,indexers,public,log}
chmod 750 /var/lib/gitea/{data,indexers,log}
chmod 770 /etc/gitea

# Copy relevant files
cp config/nginx.conf /etc/nginx/conf.d/gitea.conf
cp config/systemd.service /etc/systemd/system/gitea.service

# Set up services
systemctl daemon-reload
systemctl enable gitea
systemctl enable nginx
systemctl start gitea
systemctl start nginx

# Update nginx config
nginx -t
systemctl restart nginx

# Set up SSL certificate
certbot --nginx -d $DOMAIN
