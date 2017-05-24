#!/usr/bin/env bash
#
### HEADER
# Package Title: VPN Verifier
# ScriptTitle: Postflight
## VERSION HISTORY
# VERSION 	CONTRIBUTOR					CHANGELOG
#	1.0		conor@mac.com		Initial Development
#
### DEFINITIONS
## VARIABLES
softwareTitle=verifyVPN
sectionTitle=Header
resourceLocation=$(/usr/bin/dirname "$0")
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
echo "======STARTING VPN VERIFIER======" >> "$logFile"
echo "Executed on: $(date)" >> "$logFile"
## TEST FOR AIRWATCH APPLICATION
sectionTitle=Application
if [[ -e "/Applications/VMware AirWatch Agent.app" ]]; then
    writeLog info "AirWatch Application Present"
    ls -la "/Applications/" | /usr/bin/grep 'AirWatch' >> "$logFile"
else
    writeLog error "AirWatch Application NOT FOUND"
fi
## TEST FOR ACTIVE AIRWATCH PROCESSES
sectionTitle=Processes
processCount=$(ps aux | /usr/bin/grep -v "grep" | /usr/bin/grep -c 'AirWatch')
if [[ "$processCount" -gt 0 ]]; then
    writeLog info "Active AirWatch Process Count: $processCount"
    ps aux | /usr/bin/grep -v "grep" | /usr/bin/grep 'AirWatch' >> "$logFile"
else
    writeLog error "Active AirWatch Processes NOT FOUND"
fi
## TEST FOR MANAGEMENT VERIFICATION FILE
sectionTitle=VerficiationFile
fileCount=$(ls "/Library/Receipts/db" | /usr/bin/grep -c '.bin')
if [[ "$fileCount" -gt 0 ]]; then
    writeLog info "Management Verification File Count: $fileCount"
    ls -la "/Library/Receipts/db/" | /usr/bin/grep '.bin' >> "$logFile"
else
    writeLog error "Management Verification File NOT FOUND"
fi
#
### FOOTER
exit 0
