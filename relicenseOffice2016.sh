#!/usr/bin/env bash

### HEADER
# Package Title: Office ReActivator 1.0
# Author: Conor Schutzman <conor@mac.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=OfficeReActivator
SectionTitle=Postflight
LogFile="/Library/Logs/$SoftwareTitle.log"
TimeStamp="$(date "+%Y %b %d %T")"
ConsoleUser="$(stat -f %Su '/dev/console')"
OfficePrefLocation="/Library/Group Containers/UBF8T346G9.Office"
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## QUITTING APPS
SectionTitle=Preporation
writeLog "Quitting open Office applications"
osascript -e 'tell application "Outlook" to quit'
osascript -e 'tell application "OneNote" to quit'
osascript -e 'tell application "Word" to quit'
osascript -e 'tell application "Excel" to quit'
osascript -e 'tell application "PowerPoint" to quit'
killall "Office365ServiceV2"
## FOO
SectionTitle=CleanUp
cd "/Users/$ConsoleUser/$OfficePrefLocation"
ls -a | perl -n -e 'print if m/^[e|c]\w/' | xargs rm -v >> "$LogFile"

### FOOTER
exit 0
