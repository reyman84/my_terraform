#!/bin/bash

# Exit from the script, if any command fails
set -eou pipefail

# Check if the script is executed with root user, or normal user
if [ "$(id -u)" -ne 0 ]; then
        echo "Please execute the script with root user (or use sudo)."
        exit 1
fi

# Variables
PACKAGES=("apache2" "unzip" "wget")
SERVICE="apache2"
WEB_URL="https://www.tooplate.com/zip-templates/2137_barista_cafe.zip"
URL_FOLDER="2137_barista_cafe"
TEMP_FOLDER="/tmp/web_setup"


# Package Installation
echo "Installing required packages"
for pkg in "${PACKAGES[@]}";
do
        if dpkg -s $pkg > /dev/null 2>&1
        then
                echo "[OK] $pkg is already installed..."
        else
                echo "Installing $pkg ..."
                apt-get update -y > /dev/null
                apt-get install -y $pkg > /dev/null
                echo "$pkg installed successfully..."
        fi
done
echo


# Creating $TEMP_FOLDER
echo "Creating $TEMP_FOLDER"
mkdir -p $TEMP_FOLDER
cd $TEMP_FOLDER
echo

# Downloading and Unpackaging web url
echo "Downloading and Unpackaging web url"
wget -q $WEB_URL
unzip -q $URL_FOLDER.zip
echo

# Taking backup of /var/www/html
echo "Taking backup of /var/www/html"
if [ -d "/var/www/html" ]
then
        BACKUP_DIR="/var/www/html_backup_$(date +%F_%H-%M-%S)"
        mv /var/www/html $BACKUP_DIR
fi
echo

# Deploying Website
echo "Deploying website..."
cp -pr $URL_FOLDER /var/www/html/
echo

# Starting $SERVICE service
echo "Starting $SERVICE service"
systemctl restart $SERVICE
systemctl enable $SERVICE > /dev/null 2>&1
echo
echo "Status of $SERVICE is: $(systemctl is-active $SERVICE)"
echo

# Cleanup
echo "Cleanup $TEMP_FOLDER"
rm -rf $TEMP_FOLDER
echo

echo "Files in /var/www/html:"
ls -ltrh /var/www/html

echo
echo "End of script"
