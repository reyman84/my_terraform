#!/bin/bash

###############################################################################
# Script: fetch_system_health.sh
# Purpose: Collect system details from remote servers and copy them locally
# Author: Ramandeep
# Usage: ./fetch_system_health.sh
# Prerequisites:
#   - SSH access to the servers with passwordless authentication (SSH key-based).
#   - The user must have sudo privileges on target servers.
#   - Internet access from the servers (to download the template).
###############################################################################

# List of remote servers (IP or hostname)
SERVERS=("linux" "ubuntu")

# Remote user (should have SSH key access)
USER="devops"

###################################
# Local directory to store reports
###################################
LOCAL_DIR="$HOME/server_reports"
mkdir -p "$LOCAL_DIR"

# Date format for report filenames
DATE=$(date +%F_%H-%M-%S)

for HOST in "${SERVERS[@]}"; do
    echo "Fetching system details from $HOST ..."

    #############################################
    # Remote report file
    #############################################    
    REMOTE_FILE="/tmp/${HOST}_report_$DATE.txt"

    # Run commands on remote host
    ssh -o StrictHostKeyChecking=no "$USER@$HOST" "
        echo '===== System Report for $HOST =====' > $REMOTE_FILE
        echo 'Date: $DATE' >> $REMOTE_FILE
        echo -e '\n--- Disk Utilization ---' >> $REMOTE_FILE
        df -hT| grep -v tmpfs >> $REMOTE_FILE
        echo -e '\n--- Memory Utilization ---' >> $REMOTE_FILE
        free -h >> $REMOTE_FILE
        echo -e '\n--- Top 5 CPU consuming processes ---' >> $REMOTE_FILE
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 >> $REMOTE_FILE
        echo -e '\n--- Top 5 Memory consuming processes ---' >> $REMOTE_FILE
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 >> $REMOTE_FILE
        echo -e '\n--- Uptime ---' >> $REMOTE_FILE
        uptime >> $REMOTE_FILE
        
        echo -e '\n--- CPU Load Average ---' >> $REMOTE_FILE
        cat /proc/loadavg >> $REMOTE_FILE
        echo -e '\n--- Inodes Usage ---' >> $REMOTE_FILE
        df -i >> $REMOTE_FILE
        echo -e '\n--- Swap Usage ---' >> $REMOTE_FILE
        swapon --show >> $REMOTE_FILE
        echo -e '\n--- Open Network Ports ---' >> $REMOTE_FILE
        ss -tulpn | grep LISTEN >> $REMOTE_FILE
        echo -e '\n--- Logged-in Users ---' >> $REMOTE_FILE
        who >> $REMOTE_FILE
        echo -e '\n--- Kernel Version ---' >> $REMOTE_FILE
        uname -r >> $REMOTE_FILE
    "

    # Copy report back to local
    scp -o StrictHostKeyChecking=no "$USER@$HOST:$REMOTE_FILE" "$LOCAL_DIR/"

    echo "Report from $HOST saved to $LOCAL_DIR"
done

echo "✅ All reports collected in $LOCAL_DIR"