#!/usr/bin/env bash
#
### HEADER
# Distribution Title: CentrifyFix 1.0
# Package Title:
# ScriptTitle: Postflight
## VERSION HISTORY
# Version  Comment  Contributer
# v1.0 - Initial Development - conor@mac.com
#
### DEFINITIONS
## VARIABLES
softwareTitle=CertFix
resourceLocation=$(dirname "$0")
hostName=$(/bin/hostname)
keyChain='/Library/Keychains/System.keychain'
## IMPORT SHARED VALUES
if [[ -s "${resourceLocation}/sharedLib.sh" ]]; then
    source "${resourceLocation}/sharedLib.sh"
else
    /usr/bin/logger "Shared resources not available, quitting."
    echo "Shared resources not available, quitting."
    exit 1
fi
#
### BODY
if [[ -e '/usr/local/bin/adinfo' ]]; then
	/usr/local/bin/adinfo --version | /usr/bin/awk -F '(' '{print $2}' | /usr/bin/tr -d ')' >> "$logFile"
else
	exitError "Centrify not found."
fi
## CURRENT DEVICE CERT

if [[ $(/usr/bin/security find-certificate -c $hostName $keyChain | /usr/bin/grep labl | /usr/bin/grep -c $hostName) = 0 ]]; then
	/usr/bin/open -ng "/Applications/Utilities/Keychain Access.app"
	displayDialog "Computer's hostname does not match established pattern, device certificate cannot be removed automatically.  Please do not click Okay until you've preformed this task manually.\n \nKeychain Access has been launched, switch to it, select System from the Keychains section, then Keys from the Category section; find and delete the certfiicate named the same as your computer name."
	/usr/bin/security -q find-certificate -a /Library/Keychains/System.keychain | /usr/bin/grep 'labl' | /usr/bin/awk -F '=' '{print $2}' | /usr/bin/tr -d '"' | /usr/bin/awk '{print " - " $0}' >> "$logFile"
else
	displayNotification "Removing existing certificate."
	echo "security delete-certificate -c $(hostname) -t /Library/Keychains/System.keychain" >> "$logFile"
	/usr/bin/security delete-certificate -c "$(hostname)" -t "/Library/Keychains/System.keychain" >> "$logFile"
fi
## CERTIFICATE CACHE
if [[ -d '/var/Centrify/net/certs/' ]]; then
	displayNotification "Deleting certificate cache."
	echo "srm -fv /var/Centrify/net/certs/*" >> "$logFile"
	/usr/bin/srm -fv /var/Centrify/net/certs/* >> "$logFile"
else
	writeLog warning "Certificate Cache not found."
	ls -la /var/Centrify/net/certs >> "$logFile"
fi
## POLICY UPDATE
if [[ $(/usr/local/bin/adinfo | grep -c 'CentrifyDC mode:   connected') = 1 ]]; then
	displayNotification "Updating Group Policy"
	/usr/local/bin/adgpupdate >> "$logFile" 2>&1
else
	writeLog warning "Centrify not connected, group policy will be updated upon next connection to TE corporate network."
fi
#
### FOOTER
exit 0
