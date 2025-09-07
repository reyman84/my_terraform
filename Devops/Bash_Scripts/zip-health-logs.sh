#!/bin/bash
set -euo pipefail

LOG_DIR="/home/devops/health-report"
DATE=$(date +%F)

cd "$LOG_DIR"

# Zip all logs of the day into one archive
tar -czf health_logs_$DATE.tar.gz *.txt

# (Optional) remove original txt files after archiving
rm -f *.txt
