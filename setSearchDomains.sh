#!/usr/bin/env bash

### HEADER
# Package Title: SSO Optimizer - SysPrefs
# Author: Conor Schutzman <conor@mac.com>

### DEFINITIONS
## VARIABLES
SoftwareTitle=SSO_Optimizer
SectionTitle=SysPrefs
LogFile="/Library/Logs/$SoftwareTitle.log"
TimeStamp="$(date "+%Y %b %d %T")"
ConsoleUser="$(stat -f %Su '/dev/console')"
## ARRAYS
DomainList=(
	''
	)
## FUNCTIONS
writeLog(){ echo "[$(date "+%Y %b %d %T")] [$ConsoleUser] [$SoftwareTitle] [$SectionTitle] $1" >> "$LogFile"; }

### BODY
## LOGGING
[[ -d "$(dirname $LogFile)" ]] || mkdir -p -m 755 "$(dirname $LogFile)"
[[ -e "$LogFile" ]] || touch "$LogFile"
[[ "$(stat -f%z "$LogFile")" -ge 1000000 ]] && rm -rf "$LogFile"
## SYSPREFS
CurrentDomain="$(adinfo | grep "Joined to domain" | awk -F':' '{print $2}' | xargs)"
writeLog "Bound to Domain: $CurrentDomain"
ActiveInterfaces="$(networksetup -listallnetworkservices | grep -v '*')"
while read; do
	NetworkInterfaces+=("$REPLY")
done< <(echo "$ActiveInterfaces")
writeLog "Previous Settings:"
for EachInterface in "${NetworkInterfaces[@]}"; do
	PreviousSettings="$(networksetup -getsearchdomains "$EachInterface")"
	while read; do
		ExistingDomains+=($REPLY)
	done< <(echo "$PreviousSettings")
	echo "  [$EachInterface] $(echo ${ExistingDomains[@]})" >> "$LogFile"
	unset ExistingDomains
done
writeLog "Modified Settings:"
for EachInterface in "${NetworkInterfaces[@]}"; do
	PreviousSettings="$(networksetup -getsearchdomains "$EachInterface")"
	if [[ $(networksetup -getsearchdomains "$EachInterface" | grep -c "There aren't") = 0 ]]; then
		while read; do
			ExistingDomains+=($REPLY)
		done< <(echo "$PreviousSettings")
	fi
	CombinedDomains=("$CurrentDomain" "${ExistingDomains[@]}" "${DomainList[@]}")
	for EachEntry in "${CombinedDomains[@]}"; do
		[[ "$DomainString" =~ "$EachEntry" ]] || DomainString="$DomainString $EachEntry"
	done
	echo "  [$EachInterface] $(echo $DomainString)" >> "$LogFile"
	networksetup -setsearchdomains "$EachInterface" $DomainString
	unset ExistingDomains
	unset CombinedDomains
	unset DomainString
done

## FOOTER
exit 0
