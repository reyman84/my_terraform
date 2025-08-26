#!/bin/bash

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