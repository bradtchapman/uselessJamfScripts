#!/bin/zsh

# This script will list all the users enrolled in Touch ID
# that have "unlock with fingerprint" enabled.

# First, check if the system even supports Touch ID
# If not, bail out and report unsupported.

touchIDfunctionality=$(/usr/bin/bioutil -rs | grep "Touch ID functionality")

if [[ -z $touchIDfunctionality ]]
then
	echo "<result>Unsupported</result>"
	exit 0
fi

# Next, list all the users over UID 500 and run 'bioutil' with sudo -u .
# Only capture users that have > 0 fingerprints registered,
# and finally confirm that they have enabled unlocking the Mac.

tidEnrolledUsers=($(for i in $(ls -lan /Users/ | awk '$3 > 500 { print $9 }'); do sudo -u $i /usr/bin/bioutil -c; done | awk '/User/ && !/0 fingerprint/ { print $0 }' | awk '{ print $2 }' | sed "s_:__g" ))
tidUsersArray=()

for i in ${tidEnrolledUsers[@]}
do
	tidUser=$(ls -lan /Users/ | grep "$i" | awk 'BEGIN { RS="" ; FS="\n" } { print $1 }' | awk '{ print $9 }')
	tidStatus=$(/usr/bin/sudo -u "$tidUser" /usr/bin/bioutil -r | awk '/unlock/ && !/Effective/ { print $5 }')
	[[ $tidStatus == "1" ]] && tidUsersArray+=("$tidUser")
done

# Finally, print the results!

if [[ -n $tidUsersArray ]]
then
	echo "<result>Active Users: $tidUsersArray</result>"
else
	echo "<result>Not Enabled for Unlock</result>"
fi
