#!/usr/bin/env bash
#shellcheck shell=bash

#The script reads sportsbadgers military list https://github.com/Sportsbadger/plane-alert-db/blob/main/plane-alert-mil.csv
#and builds a list of interesting ICAOs for the feeder

#create the working directory

mkdir -p /var/filter_files

#Reading CSV from git, remove the header, cut everything after the 2nd character, remove doubles,
#write everything in one comma delimited file, remove the last comma and blank and write it to a file

curl -s https://raw.githubusercontent.com/Sportsbadger/plane-alert-db/main/plane-alert-mil.csv | sed '1d' | cut -c 1-2 | awk '!seen[$0]++' | sed ':a;N;$!ba;s/\n/, /g' | sed 's/..$//' \
 > /var/filter_files/interesting_icao

