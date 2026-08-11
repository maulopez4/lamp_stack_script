#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
apt update && sudo apt upgrade -y
apt install curl php-cli php-mbstring git unzip -y

#Instalando Webmin
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh webmin-setup-repo.sh
apt-get install webmin --install-recommends

# Instalar Apache
echo "Instalando Apache..."
apt install apache2 apache2-utils -y
systemctl enable apache2
systemctl start apache2

# Instalar MariaDB
echo "Instalando MariaDB..."
apt install mariadb-server mariadb-client -y
systemctl enable mariadb
systemctl start mariadb

# Instalar PHP y módulos comunes
echo "Instalando PHP..."
sudo apt install php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip -y

# Crear Certificado local
apt install ssl-cert -y
make-ssl-cert generate-default-snakeoil --force-overwrite
a2enmod ssl
systemctl restart apache2

# Instalar ProFTPd
apt install proftpd -y

# Instalar Composer
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm /tmp/composer-setup.php

# Install NPM
curl -fsSL https://deb.nodesource.com -o nodesource_setup.sh
bash nodesource_setup.sh
apt install nodejs -y

# Instalar UFW
apt install ufw -y
ufw allow http
ufw allow https
ufw allow 10000
ufw allow 3306
ufw allow ssh
ufw allow ftp
ufw enable
ufw reload

