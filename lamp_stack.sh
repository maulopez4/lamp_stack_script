#!/bin/bash

# Actualizar el sistema
echo "Actualizando el sistema..."
apt update && sudo apt upgrade -y
apt install curl php-cli php-mbstring git unzip

#Instalando Webmin
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh webmin-setup-repo.sh
apt-get install webmin --install-recommends

# Instalar Apache
echo "Instalando Apache..."
apt install -y apache2 apache2-utils
systemctl enable apache2
systemctl start apache2

# Instalar MariaDB
echo "Instalando MariaDB..."
apt install -y mariadb-server mariadb-client
systemctl enable mariadb
systemctl start mariadb

# Instalar PHP y módulos comunes
echo "Instalando PHP..."
sudo apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip

# Crear Certificado local
apt install ssl-cert
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
apt install nodejs

# Instalar UFW
apt install -y ufw
ufw allow http
ufw allow https
ufw allow 10000
ufw allow 3306
ufw allow ssh
ufw allow ftp
ufw enable
ufw reload

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

# Prompt for the new user_name
printf "Enter the new user_name: "
read user_name

# Check if the user already exists
if id "$user_name" &>/dev/null; then
    echo "User $user_name already exists. Please choose a different user_name."
    exit 1
fi

# Use adduser to create the user account
# adduser is a user-friendly wrapper around useradd on Debian
#adduser --disabled-password --gecos "" "$user_name"

# Add user to groups
useradd -a -G sudo,users,www-data,mysql $user_name

# Prompt for and set a password
# The --disabled-password flag above means we must set the password now
read -s -p "Enter initial password for $user_name: " PASSWORD
echo "$user_name:$PASSWORD" | chpasswd
echo "" # Newline for formatting

# Enforce password change on first login for security
passwd -e "$user_name"

echo "User $user_name details:"
echo "user_name: $user_name"
echo "Home directory: /home/$user_name"
echo "Shell: /bin/bash"
echo "Password change required on first login."

# Ajustar permisos para /var/www/html
chmod o+x /home/$user_name
mkdir -p /home/$user_name/public_html
chmod 755 /home/$user_name/public_html
ln -s /var/www/html/$user_name /home/$user_name/public_html
touch /etc/apache2/sites-available/$user_name.conf
cat $user_name.conf <<EOF
<VirtualHost *:81>
    ServerAdmin webmaster@yourdomain.com
    ServerName $user_name
    ServerAlias : $user_name
    DocumentRoot /var/www/html/$user_name

    ErrorLog ${APACHE_LOG_DIR}/$user_name_error.log
    CustomLog ${APACHE_LOG_DIR}/$user_name__access.log combined
</VirtualHost>
EOF

# Check if user creation was successful
if [ $? -eq 0 ]; then
    echo "User account for $user_name created successfully."
else
    echo "Failed to create user account."
    exit 1
fi

systemctl restart apache2
#sudo chown -R $user_name:www-data /var/www/html
#sudo chmod -R 775 /var/www/html

echo "Instalación completada con éxito."
#echo "Puedes acceder a http://tu_ip/info.php para verificar PHP."
