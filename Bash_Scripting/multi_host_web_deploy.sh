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
#   6. Enables and restarts the Apache (httpd) service.
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

# Server details
SERVERS=("web01" "web02")
USER="devops"

# Website details
PACKAGES=("httpd" "wget" "unzip")
SVC="httpd"
WEB_URL="https://www.tooplate.com/zip-templates/2137_barista_cafe.zip"
WEB_FOLDER="2137_barista_cafe"
TEMP_FOLDER="/tmp/web_setup"

for HOST in "${SERVERS[@]}";
do
    ssh -o StrictHostKeyChecking=no "$USER@$HOST" "
        echo '################## Checking if required packages are installed on $HOST... ##################'

        for pkg in ${PACKAGES[@]}; do
            if rpm -q \$pkg > /dev/null 2>&1; then
                echo \"[OK] \$pkg is already installed...\"
            else
                echo \"Installing \$pkg...\"
                sudo yum install -y \$pkg > /dev/null 2>&1
            fi
        done

        echo -e '\n################## Deploying website on $HOST ##################'

        # Creating $TEMP_FOLDER
        sudo mkdir -p $TEMP_FOLDER
        cd $TEMP_FOLDER

        # Downloading and Unpackaging of WEB URL
        sudo wget -q ${WEB_URL} -O ${WEB_FOLDER}.zip
        sudo unzip -q ${WEB_FOLDER}.zip

        # Taking backup of /var/www/html, if exists
        if [ -d '/var/www/html' ]; then
            DATE=\$(date +%F_%H-%M-%S)
            BACKUP_FOLDER=\"/var/www/html_backup_\$DATE\"
            sudo mv /var/www/html \$BACKUP_FOLDER
        fi

        echo -e '\nDeploying website'
        sudo cp -pr $WEB_FOLDER /var/www/html

        # Restarting $SVC
        sudo systemctl enable $SVC > /dev/null 2>&1
        sudo systemctl restart $SVC

        echo -e '\nStatus of $SVC is:'
        systemctl is-active $SVC

        echo -e '\nClean-up'
        sudo rm -rf $TEMP_FOLDER

        #echo -e '\nListing deployed files:'
        #ls -ltrh /var/www/html | grep -v total
    "
done