#!/usr/bin/env bash
#
### HEADER
# Package Title: gatherInformation
# Script Title: regionList
# Version   Contributor                 Changelog
#   2.0     conor@mac.com      Initial development of branch.
#   2.0.1   conor@mac.com      Suppressing regions not present in sandbox.
#
### DEFINITIONS
## ARRAYS
availableRegions[0]='United States'
availableRegions[1]='Austria'
availableRegions[2]='Belgium'
availableRegions[3]='Canada'
availableRegions[4]='China'
availableRegions[5]='Czech Republic'
availableRegions[6]='France'
availableRegions[7]='Germany'
availableRegions[8]='Hong Kong'
availableRegions[9]='Hungary'
availableRegions[10]='Indonesia'
availableRegions[11]='Italy'
availableRegions[12]='Japan'
availableRegions[13]='Korea'
availableRegions[14]='Mexico'
availableRegions[15]='Netherlands'
availableRegions[16]='Poland'
availableRegions[17]='Portugal'
availableRegions[18]='Spain'
availableRegions[19]='Switzerland'
availableRegions[20]='Taiwan'
availableRegions[21]='Ukraine'
availableRegions[22]='United Kingdom'
availableRegions[23]='Other - APAC'
availableRegions[24]='Other - AMER-S'
availableRegions[25]='Other - EMEA'
availableRegions[26]='Other - EMEA-N'
availableRegions[27]='Other - Unlisted'
regionCodes[0]='us'
regionCodes[1]='at'
regionCodes[2]='be'
regionCodes[3]='ca'
regionCodes[4]='cn'
regionCodes[5]='cz'
regionCodes[6]='fr'
regionCodes[7]='de'
regionCodes[8]='hk'
regionCodes[9]='hu'
regionCodes[10]='in'
regionCodes[11]='it'
regionCodes[12]='jp'
regionCodes[13]='kr'
regionCodes[14]='mx'
regionCodes[15]='nl'
regionCodes[16]='pl'
regionCodes[17]='pt'
regionCodes[18]='es'
regionCodes[19]='ch'
regionCodes[20]='tw'
regionCodes[21]='ua'
regionCodes[22]='gb'
regionCodes[23]='apac'
regionCodes[24]='amer-s'
regionCodes[25]='emea'
regionCodes[26]='emea-n'
regionCodes[27]='other'
## SUB ROUTINES
promptRegion(){
    writeLog notice "Please select your region:"
	holdingFile=$(mktemp /tmp/region.XXXX)
	for eachRegion in "${availableRegions[@]}"; do
	    echo "$eachRegion" >> "$holdingFile"
	done
    /usr/bin/osascript <<EOT
    set regionFile to do shell script "echo $holdingFile"
    set fileHandle to open for access regionFile
    set regionList to paragraphs of (read fileHandle)
    tell application (path to frontmost application as text)
        return (choose from list regionList with title "MacIT" with prompt "Please select your region:")
    end tell
    close access fileHandle
EOT
	rm "$holdingFile"
}