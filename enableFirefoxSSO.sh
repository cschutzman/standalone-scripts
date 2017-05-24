#!/usr/bin/env bash

### HEADER
# Package Title: SSO Optimizer - Firefox
# Author: Conor Schutzman <conor@mac.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=SSO_Optimizer
SectionTitle=Firefox
LogFile="/Library/Logs/TEIS/$SoftwareTitle.log"
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
## FIREFOX
FirefoxFound="$(mdfind -onlyin "/Applications" -name "Firefox" | grep -c "Firefox")"
if [[ "FirefoxFound" -gt 0 ]]; then
	FirefoxLocation="$(mdfind -onlyin "/Applications" -name "Firefox" | head -n 1)"
	writeLog "Location: $FirefoxLocation"
	writeLog "Version: $(defaults read "$FirefoxLocation/Contents/Info.plist" CFBundleShortVersionString)"
	ProfileFolder="/Users/$ConsoleUser/Library/Application Support/Firefox"
	DefaultProfile="$(cat "$ProfileFolder/profiles.ini" | grep "Path=" | awk -F= '{print $2}')"
	writeLog "Profile: $DefaultProfile"
	writeLog "Authorizing Domain: $KDomain"
	sudo -u "$ConsoleUser" echo 'user_pref("network.negotiate-auth.delegation-uris", "$CorporateDomain");' >> "$ProfileFolder/$DefaultProfile/prefs.js"
	sudo -u "$ConsoleUser" echo 'user_pref("network.negotiate-auth.trusted-uris", "$CorporateDomain");' >> "$ProfileFolder/$DefaultProfile/prefs.js"
else
	writeLog "Not Found"
fi

## FOOTER
exit 0
