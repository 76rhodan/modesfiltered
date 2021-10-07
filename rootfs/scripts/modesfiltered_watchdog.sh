#!/usr/bin/env bash
#shellcheck shell=bash

# This script:
#   - Checks the last 100 lines of the modesfiltered log file
#   - Gets the latest MSG entry
#   - If the MSG entry is older than 600 seconds pkill the task (and s6-svc will restart it automatically)

# Get latest MSG line from last 100 lines of log
LAST_MSG_LOG_ENTRY=$(tail -100 "${MODESFILTERED_LOG_PATH}/current" | grep "MSG, " | tail -1)

# Get date/time string from log entry
LAST_MSG_LOG_ENTRY_DATETIMESTR=$(echo $LAST_MSG_LOG_ENTRY | tr -d " " | cut -d "," -f4,5 | tr "," " " | tr "/" "-")

# Get seconds since epoch from date/time string
LAST_MSG_LOG_ENTRY_SECONDS=$(date -d "$(echo $LAST_MSG_LOG_ENTRY_DATTIMESTR)" +%s)

# Get seconds since epoch for now
NOW_SECONDS=$(date +%s)

# Get how old the last MSG line is (in seconds)
LAST_MSG_LOG_ENTRY_AGE=$((LAST_MSG_LOG_ENTRY_SECONDS - NOW_SECONDS))

# If the log entry is older than 5 minutes (600)...
if [[ $LAST_MSG_LOG_ENTRY_AGE -ge 600 ]]; then
    echo "[watchdog] Last MSG processed more than 600 seconds ago. Restarting modesfiltered."
    pkill "java"
fi
