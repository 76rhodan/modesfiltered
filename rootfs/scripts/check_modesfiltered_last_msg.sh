#!/usr/bin/env bash
#shellcheck shell=bash

# This script:
#   - Checks the last 100 lines of the modesfiltered log file
#   - Gets the latest MSG entry
#   - If the MSG entry is older than 600 seconds pkill the task (and s6-svc will restart it automatically)

# Get latest MSG line from last 100 lines of log

# If the env variable MAX_LOG_TIME is not set, assume it to be 600 secs
[[ -z "$MAX_LOG_TIME" ]] && MAX_LOG_TIME=600

LAST_MSG_LOG_ENTRY=$(tail -100 "${MODESFILTERED_LOG_PATH}/current" | grep "MSG, " | tail -1)

# Get date/time string from log entry
LAST_MSG_LOG_ENTRY_DATETIMESTR=$(echo $LAST_MSG_LOG_ENTRY | tr -d " " | cut -d "," -f4,5 | tr "," " " | tr "/" "-")

# Get seconds since epoch from date/time string
LAST_MSG_LOG_ENTRY_SECONDS=$(date -d "$(echo $LAST_MSG_LOG_ENTRY_DATETIMESTR)" +%s)

# Get seconds since epoch for now
NOW_SECONDS=$(date +%s)

# Get how old the last MSG line is (in seconds)
LAST_MSG_LOG_ENTRY_AGE=$((NOW_SECONDS - LAST_MSG_LOG_ENTRY_SECONDS))

# If the log entry is older than 10 minutes (600)...
if [[ $LAST_MSG_LOG_ENTRY_AGE -ge $MAX_LOG_TIME ]]; then
    echo "[watchdog][$(date +"%Y/%m/%d %H:%M:%S")] modesfiltered services will be restarted: Last MSG processed more than $MAX_LOG_TIME seconds ago"
    exit 1
else
    if [[ -n "$VERBOSE" ]]; then
        echo "[watchdog][$(date +"%Y/%m/%d %H:%M:%S")] modesfiltered services appear OK: last MSG processed $LAST_MSG_LOG_ENTRY_AGE seconds ago"
        exit 0
    fi
fi
