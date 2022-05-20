#!/bin/zsh

osVersion=$(sw_vers -BuildVersion | cut -c 1,2)
jh="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# Time Machine snapshots are available on macOS 10.13.6 and higher; however,
# on macOS 10.14.6 and below, the 'deletelocalsnapshots' verb requires specifying
# each snapshot.  Therefore, the below will not work.

if [[ $osVersion -ge 19 ]]
then
	echo "Stopping Time Machine and deleting snapshots..."
    
	/usr/bin/tmutil stopbackup > 2>&1
	sleep 2
	/usr/bin/tmutil deletelocalsnapshots / 2>&1
fi

# DocumentRevisions-V100 folder is in two different places depending on the OS.
# In Mojave and below, it's in the root folder directly.
# In Catalina+ it is moved to the "Data" volume and must be accessed via /System/Volumes/Data.

if [[ $osVersion -lt 19 ]]
then
	docRevisionsFolder="/.DocumentRevisions-V100"
else
	docRevisionsFolder="/System/Volumes/Data/.DocumentRevisions-V100"
fi

echo "Clearing the DocumentRevisions folder..."
/bin/rm -rf "$docRevisionsFolder"/* 2>&1

echo "The computer MUST be restarted now."

"$jh" -windowType utility -title "Self Service Disk Cleanup" \
-heading "Disk cleanup complete.  Restart required." \
-description "The cleanup actions require your Mac to be restarted immediately.  Please save your work and prepare to reboot." \
-icon "/System/Library/CoreServices/Dock.app/Contents/Resources/trashfull@2x.png" -iconSize 128 \
-timeout 120 -countdown -alignCountdown right -button1 "OK"

/bin/launchctl reboot apps

sleep 5

/bin/launchctl reboot system
