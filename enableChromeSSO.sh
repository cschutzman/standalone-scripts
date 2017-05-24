#!/usr/bin/env bash

### HEADER
# Package Title: SSO Optimizer - Chrome
# Author: Conor Schutzman <conor@mac.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=SSO_Optimizer
SectionTitle=Chrome
LogFile="/Library/Logs/$SoftwareTitle.log"
TimeStamp="$(date "+%Y %b %d %T")"
ConsoleUser="$(stat -f %Su '/dev/console')"
CorporateDomain=''
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## CHROME
ChromeFound="$(mdfind -onlyin "/Applications" -name "Chrome" | grep -c "Chrome")"
if [[ "ChromeFound" -gt 0 ]]; then
	ChromeLocation="$(mdfind -onlyin "/Applications" -name "Chrome" | head -n 1)"
	writeLog "Location: $ChromeLocation"
	writeLog "Version: $(defaults read "$ChromeLocation/Contents/Info.plist" CFBundleShortVersionString)"
	writeLog "Authorizing Domain: $KDomain"
	sudo -u "$ConsoleUser" defaults write com.google.Chrome AuthServerWhitelist "*.$CorporateDomain"
	sudo -u "$ConsoleUser" defaults write com.google.Chrome AuthNegotiateWhitelist "*.$CorporateDomain"
else
	writeLog "Not Found"
fi

## FOOTER
exit 0
