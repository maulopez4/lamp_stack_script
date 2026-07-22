#!/bin/sh
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
useradd -aG sudo,users,www-data,mysql $user_name

# Prompt for and set a password
# The --disabled-password flag above means we must set the password now
read -s -p "Enter initial password for $user_name: " PASSWORD
echo "$user_name:$PASSWORD" | chpasswd
echo "" # Newline for formatting

# Enforce password change on first login for security
#passwd -e "$user_name"

echo "User $user_name details:"
echo "user_name: $user_name"
echo "Home directory: /home/$user_name"
echo "Shell: /bin/bash"
#echo "Password change required on first login."

# Ajustar permisos para /var/www/html
chmod o+x /home/$user_name
mkdir -p /home/$user_name/public_html
chmod 755 /home/$user_name/public_html
ln -s /var/www/html/$user_name /home/$user_name/public_html
touch /etc/apache2/sites-available/$user_name.conf
cat /etc/apache2/sites-available/$user_name.conf <<EOF
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
