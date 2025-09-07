#!/bin/bash
################################################################################
# Script Name: package_installation.sh
# Description: Checks if given services (httpd, docker, etc.) are installed, 
#              installs them if missing, ensures they are running, 
#              and enables them to start on boot.
#
# Usage: ./package_installation.sh
#
# Author: Ramandeep
# Date:   2025-08-27
#
# Requirements:
#   - Must be run on a Linux system with rpm/yum and systemd
#   - User must have sudo privileges for package installation and service management
#
# Tested on:
#   - RHEL / CentOS / Amazon Linux
#
# Exit Codes:
#   0  - Successful execution
#   >0 - Failure (set -euo pipefail will stop execution on errors)
#
# Notes:
#   - Modify the SERVICES array to include any services you want to manage.
#   - Output is redirected to /dev/null for cleaner logs except for status messages.
################################################################################

set -euo pipefail

SERVICES=("httpd" "docker")

for svc in "${SERVICES[@]}"; do
    echo "=== Checking $svc ==="

    # 1. Check if installed
    if ! rpm -q $svc &>/dev/null; then
        echo "$svc is not installed. Installing..."
        sudo yum install -y $svc >/dev/null 2>&1
    else
        echo "$svc is already installed."
    fi

    # 2. Check if running
    if systemctl is-active --quiet $svc; then
        echo "$svc service is already running."
    else
        echo "Starting $svc service..."
        sudo systemctl start $svc
    fi

    # 3. Enable on boot
    if systemctl is-enabled --quiet $svc; then
        echo "$svc is already enabled at boot."
    else
        echo "Enabling $svc to start on boot..."
        sudo systemctl enable $svc >/dev/null 2>&1
    fi

    echo
    sleep 2
done