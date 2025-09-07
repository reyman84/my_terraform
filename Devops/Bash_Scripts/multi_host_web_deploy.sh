#!/bin/bash

###############################################################################
# Script Name   : multi_host_web_deploy.sh
# Description   : Automates the deployment of a static website on multiple 
#                 remote servers. The script installs required packages, 
#                 downloads a website template, backs up existing web content, 
#                 deploys the new site, and ensures Apache (httpd) is running.
#
# Author        : Ramandeep Singh
# Date Created  : 2025-08-25
# Version       : 1.0
#
# Usage         : ./multi_host_web_deploy.sh
#
# Servers       : web01, web02  (configured in SERVERS array)
# User          : devops        (SSH user used for remote execution)
#
# Prerequisites :
#   - SSH access to the servers with passwordless authentication (SSH key-based).
#   - The user must have sudo privileges on target servers.
#   - Internet access from the servers (to download the template).
#
# Actions Performed:
#   1. Checks and installs required packages: httpd, wget, unzip.
#   2. Creates a temporary working directory on remote servers.
#   3. Downloads and extracts a Tooplate website template.
#   4. Backs up existing /var/www/html directory if present.
#   5. Deploys the new website into /var/www/html.
#   6. Enables and restarts the httpd service (apache2 for ubuntu).
#   7. Cleans up temporary files after deployment.
#
# Exit Codes:
#   0 : Success
#   1 : Failure in SSH connection or command execution
#
# Notes:
#   - Update SERVERS array to add/remove target servers.
#   - Change WEB_URL and WEB_FOLDER to use a different template.
###############################################################################

set -eou pipefail

# List of remote servers (IP or hostname)
SERVERS=("web01" "web02")
USER="devops"

for HOST in "${SERVERS[@]}"; do
        echo "----- Logging to $HOST -----"
        ssh -o StrictHostKeyChecking=no "$USER@$HOST" '

                echo -e "\nEnsure required packages are installed and httpd is running..."
                # Required packages
                PACKAGE=("httpd" "unzip" "wget")
                SERVICE="httpd"
                for pkg in "${PACKAGE[@]}"; do
                        if ! rpm -q $pkg > /dev/null 2>&1
                        then
                                echo "Installing $pkg..."
                                sudo yum install -y $pkg &>/dev/null
                        else
                                echo "[OK] $pkg is already installed"
                        fi
                done

                # Ensure httpd is running
                if systemctl is-active --quiet $SERVICE > /dev/null 2>&1
                then
                        echo "[OK] $SERVICE is already running"
                else
                        echo "Starting $SERVICE..."
                        sudo systemctl restart $SERVICE
                        echo "Status of $SERVICE is: $(systemctl is-active $SERVICE)"
                fi

                # Ensure httpd is enabled at boot
                if systemctl is-enabled --quiet $SERVICE > /dev/null 2>&1
                then
                        echo "[OK] $SERVICE is already enabled at boot..."
                else
                        echo "$SERVICE is not enabbled at boot"
                        echo "Enabling $SERVICE at boot..."
                        sudo systemctl enable $SERVICE > /dev/null 2>&1
                fi

                echo -e "\n----- Deploying Website -----"
                # Website Variables
                WEB_URL="https://www.tooplate.com/zip-templates/2137_barista_cafe.zip"
                WEB_DIR="2137_barista_cafe"
                TEMP_DIR="/tmp/web-setup"

                mkdir -p $TEMP_DIR
                cd $TEMP_DIR

                wget $WEB_URL &> /dev/null
                unzip $WEB_DIR.zip > /dev/null

                # Backup of /var/www/html
                if [ -d "/var/www/html" ]; then
                        BACKUP_DIR="/var/www/html_BACKUP_$(date +%F_%H-%M-%S)"
                        echo -e "\nBackup of /var/www/html"
                        sudo mv /var/www/html $BACKUP_DIR
                fi

                sudo cp -pr ${WEB_DIR} /var/www/html

                echo -e "\nRestarting $SERVICE"
                sudo systemctl restart $SERVICE

                echo -e "\nStatus of $SERVICE is: $(systemctl is-active $SERVICE)"

                # Cleanup
                echo -e "\nCleaning up temporary files..."
                rm -rf $TEMP_DIR

                echo -e "\nListing deployed files:"
                ls -ltrh /var/www/html | grep -v total
                echo -e "\n------------------------------------------------ Completed on '"$HOST"' ------------------------------------------------"
        '
done