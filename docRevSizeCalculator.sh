#!/bin/bash

# You will need a corresponding Jamf Extension Attribute or other tool
# to read the values stored in the .plist file for use elsewhere.

reverseEApath="/var/tmp/docRevCalculations.plist"

macosversion=$(sw_vers -buildVersion | cut -c 1,2)

# DocumentRevisions-V100 is stored at the root folder in Mojave
# and has been moved into the Data volume in Catalina+.

if [[ $macosversion -ge "19" ]]
then
	docRevFolder="/System/Volumes/Data/.DocumentRevisions-V100"
else
	docRevFolder="/.DocumentRevisions-V100"
fi

# This part takes the total of the DocumentRevision folder
# And compares it to the % of free disk space and total disk size.
# These values are percentages expressed as whole integers,
# since Jamf cannot store fractional or floating point numbers.
# For example: a value of DRSPercentOfFreeSpace = 100 means that
# the DRV folder size is exactly as large as the disk free space.
# And a value of DRSPercentOfDiskSize should not exceed 100.

docRevSize=$(du -sm "$docRevFolder" | awk '{ print $1 }') 
diskSize=$(df -lm / | tail -1 | awk '{ print $2 }')
diskFree=$(df -lm / | tail -1 | awk '{ print $4 }')
DRSPercentOfDiskSize=$(echo "100 * $docRevSize / $diskSize" | bc)
DRSPercentOfFreeSpace=$(echo "100 * $docRevSize / $diskFree" | bc)

defaults write "$reverseEApath" docRevSize $docRevSize
defaults write "$reverseEApath" diskSize $diskSize
defaults write "$reverseEApath" diskFree $diskFree
defaults write "$reverseEApath" DRSPercentOfDiskSize $DRSPercentOfDiskSize
defaults write "$reverseEApath" DRSPercentOfFreeSpace $DRSPercentOfFreeSpace
