#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check ROOT Privileges
if [ "$(id -u)" -ne 0 ]; then
        echo "Please run this script with root (or with sudo)."
        exit 1
fi

# Variable Declaration
PACKAGES=("apache2" "unzip" "wget")
SERVICE="apache2"
TEMP_DIR="/tmp/web_setup"
URL="https://www.tooplate.com/zip-templates/2122_nano_folio.zip"
URL_FOLDER="2122_nano_folio"

# Installing: $PACKAGES"
for pkg in "${PACKAGES[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "[OK] $pkg is already installed"
    else
        echo "[INFO] Installing $pkg..."
        apt-get update -y
        apt-get install -y "$pkg"
    fi
done
echo "All required packages are installed."
echo

# Creating temporary folder"
echo "Creating Temporary folder: $TEMP_DIR"
mkdir -p $TEMP_DIR
cd $TEMP_DIR


# Downloading website URL
wget -q $URL


# Unzipping URL
unzip -q $URL_FOLDER.zip > /dev/null
echo

# Taking backup of previous folders"
if [ -d "/var/www/html" ]; then
    BACKUP_DIR="/var/www/html_backup_$(date +%F_%H-%M-%S)"
    echo "📂 Backing up existing /var/www/html to $BACKUP_DIR"
    mv /var/www/html/ $BACKUP_DIR
fi

# Copy files to /var/www/html
cp -pr $URL_FOLDER /var/www/html/
echo

echo "#################################"
echo "# Checking files in the folders"
echo "#################################"
ls -l /var/www/html

# Enabling $SERVICE
systemctl enable $SERVICE 2> /dev/null
echo

# Restarting $SERVICE
echo "#################################"
echo " Restarting $SERVICE service"
echo "#################################"
systemctl restart $SERVICE
echo

echo "#################################"
echo "Status of $SERVICE"
echo "#################################"
echo "✅ $SERVICE is now: $(systemctl is-active $SERVICE)"
echo

# Cleanup
echo "#################################"
echo "Cleaning $TEMP_DIR"
echo "#################################"
rm -rf $TEMP_DIR
ls /tmp
echo
echo
echo "End of the script"