#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl php-cli php-mbstring git unzip

#Instalando Webmin
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sudo sh webmin-setup-repo.sh
sudo apt-get install webmin --install-recommends

# Instalar Apache
echo "Instalando Apache..."
sudo apt install -y apache2 apache2-utils
sudo systemctl enable apache2
sudo systemctl start apache2

# Instalar MariaDB
echo "Instalando MariaDB..."
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Instalar PHP 8.4 y módulos comunes
echo "Instalando PHP 8.4..."
sudo apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip

# Instalar ProFTPd
sudo apt install proftpd -y

# Instalar Composer
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo rm /tmp/composer-setup.php

# Install NPM
curl -fsSL https://deb.nodesource.com -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs

# Instalar UFW
sudo apt install -y ufw
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 10000
sudo ufw allow ssh
sudo ufw enable
sudo ufw reload

# Ajustar permisos para /var/www/html
#sudo chown -R $USER:www-data /var/www/html
#sudo chmod -R 755 /var/www/html

# Crear archivo de prueba info.php
#echo "<?php phpinfo(); ?>" > /var/www/html/info.php

echo "Instalación completada con éxito."
#echo "Puedes acceder a http://tu_ip/info.php para verificar PHP."

