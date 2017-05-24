#!/usr/bin/env bash
#
### HEADER
# AirWatch Software Catalog Self Service Script
# Product Title: Reset Lync Keychains
## VERSION HISTORY
# VERSION 	CONTRIBUTOR					CHANGELOG
#	1.0		conor@mac.com        		Initial Development
#
### DEFINITIONS
## VARIABLES
logTitle=SelfService
productTitle=LyncKeychain
logFolder="/Library/Logs"
logFile="${logFolder}/${logTitle}.log"
consoleUser=$(/usr/bin/stat -f %Su '/dev/console')
homeFolder=$(dscl . -read /Users/${consoleUser} NFSHomeDirectory | awk '{print $2}')
prefFile='com.microsoft.Lync.plist'
## FUNCTIONS
writeLog(){ /usr/bin/logger -s -t "${consoleUser} ${productTitle}" -p "user.${1}" "$2" 2>> "$logFile"; }
exitError(){
    /usr/bin/osascript > /dev/null <<EOT
    tell application (path to frontmost application as text)
        display dialog "$1" buttons {"Quit"} default button 1 with title "Mac IT" with icon Stop
    end tell
EOT
exit 1
}
displayDialog(){
    /usr/bin/osascript > /dev/null <<EOT
    tell application (path to frontmost application as text)
        display dialog "$1" buttons {"OK"} default button 1 with title "Mac IT"
    end tell
EOT
}
## LOGGING
[[ -d "$logFolder" ]] || mkdir -p -m 775 "$logFolder"
[[ $(/usr/bin/stat -f %u "$logFolder") -ne 0 ]] && /usr/sbin/chown -R root "$logFolder"
[[ $(/usr/bin/stat -f %g "$logFolder") -ne 0 ]] && /usr/bin/chgrp -R wheel "$logFolder"
[[ $(/usr/bin/stat -f %p "$logFolder") -ne 40755 ]] && /usr/sbin/chown -R 755 "$logFolder"
if [[ -e "$logFile" ]]; then
  [[ $(/usr/bin/stat -f %z "$logFile") -ge 1000000 ]] && mv "$logFile" "${logFile}.old"
fi
/usr/bin/touch "$logFile"
[[ $(/usr/bin/stat -f %u "$logFile") -ne 0 ]] && /usr/sbin/chown -R root "$logFile"
[[ $(/usr/bin/stat -f %g "$logFile") -ne 0 ]] && /usr/bin/chgrp -R wheel "$logFile"
[[ $(/usr/bin/stat -f %p "$logFile") -ne 100644 ]] && /usr/sbin/chown -R 644 "$logFile"
#
### BODY
displayDialog "This script will attempt to remove any Lync-related keychains for the current user, thus resolving any access errors caused by those keychains being corrupt or damaged."
osascript -e 'tell application "Lync" to quit'
if [[ -e "${homeFolder}/Library/Preferences/${prefFile}" ]]; then
	lyncUser=$(/usr/bin/defaults read "${homeFolder}/Library/Preferences/${prefFile}" UserIDMRU | /usr/bin/grep UserID | /usr/bin/awk -F '"' '{print $2}')
	writeLog info "Active Lync UserID: $lyncUser"
else
	exitError "Unable to determine Lync UserID.  This process cannot continue, and no files have been modified."
fi
if [[ -e "${homeFolder}/Library/Keychains/OC_KeyContainer__$lyncUser" ]]; then
	writeLog info "Removing Lync Keychain files:"
	rm -Rfv "${homeFolder}/Library/Keychains/OC_KeyContainer__$lyncUser" >> "$logFile"
else
	ls -la "${homeFolder}/Library/Keychains" >> "$logFile"
	exitError "No Lync OC Key Container Keychains found, no files have been removed."
fi
displayDialog "All Lync OC Key Container Keychains for this user have been successfully removed."
#
### FOOTER
exit 0
