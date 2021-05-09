#!/bin/zsh

isPairingActive=""
pairingRecordsPath="/Library/Sharing/AutoUnlock/pairing-records.plist"
unlockingWithWatch=()

listOfUsers=($(/bin/ls -1 /Users/ ))

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

if [[ ${#unlockingWithWatch[@]} == 0 ]]
then
        echo "<result>Inactive</result>"
else
        echo "<result>Active: ${unlockingWithWatch[@]}</result>"
fi

