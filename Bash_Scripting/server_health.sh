#!/bin/bash
#
# Script: fetch_system_health.sh
# Purpose: Collect system details from remote servers and copy them locally
# Author: Ramandeep
# Usage: ./fetch_system_health.sh

# List of remote servers (IP or hostname)
SERVERS=("web01" "web02")

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
    REMOTE_REPORT="/tmp/${HOST}_report_$DATE.txt"

    # Run commands on remote host
    ssh -o StrictHostKeyChecking=no "$USER@$HOST" "
        echo '===== System Report for $HOST =====' > $REMOTE_REPORT
        echo 'Date: $(date)' >> $REMOTE_REPORT
        echo -e '\n--- Disk Utilization ---' >> $REMOTE_REPORT
        df -h >> $REMOTE_REPORT
        echo -e '\n--- Memory Utilization ---' >> $REMOTE_REPORT
        free -h >> $REMOTE_REPORT
        echo -e '\n--- Top 5 CPU consuming processes ---' >> $REMOTE_REPORT
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 >> $REMOTE_REPORT
        echo -e '\n--- Top 5 Memory consuming processes ---' >> $REMOTE_REPORT
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 >> $REMOTE_REPORT
        echo -e '\n--- Uptime ---' >> $REMOTE_REPORT
        uptime >> $REMOTE_REPORT
    "

    # Copy report back to local
    scp -o StrictHostKeyChecking=no "$USER@$HOST:$REMOTE_REPORT" "$LOCAL_DIR/"

    echo "Report from $HOST saved to $LOCAL_DIR"
done

echo "✅ All reports collected in $LOCAL_DIR"