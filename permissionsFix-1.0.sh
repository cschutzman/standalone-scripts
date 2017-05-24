#!/usr/bin/env bash
#
### HEADER
# AirWatch Software Catalog Self Service Script
# Product Title: Permissions Fix
## VERSION HISTORY
# VERSION 	CONTRIBUTOR					CHANGELOG
#	1.0		conor@mac.com        		Initial Development
#
### DEFINITIONS
## VARIABLES
logTitle=SelfService
productTitle=permissionsFix
logFolder="/Library/Logs/TEIS"
logFile="${logFolder}/${logTitle}.log"
# currentUsers=$(dscacheutil -q user | grep -e dir:\ /Users/ | awk -F '/' '{print $3}')
## FUNCTIONS
writeLog(){ /usr/bin/logger -s -t "${consoleUser} ${productTitle}" -p "user.${1}" "$2" 2>> "$logFile"; }
promptInput(){
    /usr/bin/osascript <<EOT
    tell application (path to frontmost application as text)
        text returned of (display dialog "$1" default answer "$2" buttons {"Quit","OK"} default button 2 cancel button 1 with title "Mac IT")
    end tell
EOT
    if [[ "$?" = "1" ]]; then
        writeLog err "User opted to exit."
        exit 1
    fi
}
exitError(){
	writeLog err "$1"
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
        display dialog "$1" buttons {"OK"} default button 1 with title "TEIS Mac"
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
# USERNAME PROMPT
usernameConfirmed=0
while [[ "$usernameConfirmed" = 0 ]]; do
    enteredUsername=$(promptInput "Please enter your eight-digit User ID:" "01234567")
    [[ "$?" != 0 ]] && exit 1
    if [[ "$enteredUsername" = '01234567' ]]; then
        enteredUsername=$(promptInput "Default text was entered, please replace the default text with your User ID." "01234567")
        [[ "$?" != 0 ]] && exit 1
        if [[ "$enteredUsername" = '01234567' ]]; then
            writeLog warning "User entered default text for first username prompt"
        fi
    fi
    confirmUsername=$(promptInput "Please retype your User ID for confirmation." "01234567")
    [[ "$?" != 0 ]] && exit 1
    if [[ "$confirmUsername" = '01234567' ]]; then
        confirmUsername=$(promptInput "Default text was entered, please retype your User ID for confirmation." "01234567")
        [[ "$?" != 0 ]] && exit 1
        if [[ "$confirmUsername" = '01234567' ]]; then
            writeLog warning "User entered default text for User ID confirmation"
        fi
    fi
    if [[ "$enteredUsername" = '01234567' ]] || [[ "$confirmUsername" = '01234567' ]]; then
        displayDialog "Default text was provided multiple times, please try again."
    elif [[ "$enteredUsername" != "$confirmUsername" ]]; then
        displayDialog "User ID entries did not match, please try again."
    elif [[ "${#enteredUsername}" != 8 ]]; then
        displayDialog "User ID does not appear to be following established TE format, please try again."
    else
        writeLog info "Confirmed User ID: $enteredUsername"
        (( usernameConfirmed++ ))
        break
    fi
done
if [[ "$enteredUsername" = '01234567' ]] || [[ -z "$enteredUsername" ]]; then
    exitError "An error occured during User ID entry.\n \nPlease restart this process."
fi
## USER DATA
userFound=$(/usr/bin/dscl . -list /Users | /usr/bin/grep -v '_' | /usr/bin/grep -c "$enteredUsername")
if [[ "$userFound" -eq 0 ]]; then
	exitError "User $enteredUsername not found on this system. No permissions have been modified.\n \nPlease confirm your username and restart this process."
fi
uniqueIdentifier=$(/usr/bin/dscl . -read "/Users/$enteredUsername" UniqueID | /usr/bin/awk '{print $2}')
homeFolder=$(/usr/bin/dscl . -read "/Users/$enteredUsername" NFSHomeDirectory | /usr/bin/awk '{print $2}')
primaryGroup=$(/usr/bin/dscl . -read "/Users/$enteredUsername" PrimaryGroupID | /usr/bin/awk '{print $2}')
## FIX HOME FOLDER
/usr/bin/find "$homeFolder" ! -uid "$uniqueIdentifier" -exec /usr/sbin/chown "$uniqueIdentifier":"$primaryGroup" {} \;
/usr/bin/find "$homeFolder" ! -gid "$primaryGroup" -exec /usr/bin/chgrp "$primaryGroup" {} \;
#
### FOOTER
displayDialog "Permissions have been reset successfully."
exit 0
