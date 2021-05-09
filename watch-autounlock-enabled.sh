#!/bin/zsh

# Variable initialization and declarations
# the 'pairing-records' file contains key values when
# when AutoUnlock is enabled.  If not, the file is devoid of keys.


isPairingActive=""
pairingRecordsPath="/Library/Sharing/AutoUnlock/pairing-records.plist"
unlockingWithWatch=()

listOfUsers=($(/bin/ls -1 /Users/ ))

# Check all users.  If the specific pairing-record file isn't found, nothing happens.
# The execution time of this script is fast enough not to warrant further optimization.
# If a pairing record is found and not empty, record the user in the array.
#
# NOTE: although Apple only supports one user unlocking with a Watch today,
# The use of an array is my way of future-proofing in case Apple changes their mind :-)

for i in ${listOfUsers[@]};
do
        pairingRecord="/Users/$i/$pairingRecordsPath"
        isUnlocking=$(/usr/libexec/PlistBuddy -c "print" -x /Users/$i/Library/Sharing/AutoUnlock/pairing-records.plist | xmllint --xpath "(//key)[1]/text()" - 2>/dev/null)

        if [[ -f $pairingRecord ]]
        then
                if [[ -n $isUnlocking ]]
                then
                        unlockingWithWatch+=("$i")
                fi
        fi
done

# Print the results for a Jamf Extension Attribute

if [[ ${#unlockingWithWatch[@]} == 0 ]]
then
        echo "<result>Inactive</result>"
else
        echo "<result>Active: ${unlockingWithWatch[@]}</result>"
fi

