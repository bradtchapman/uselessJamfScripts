#!/bin/bash

# BEFORE RUNNING THIS SCRIPT
# YOU MUST DO THE FOLLOWING:
#
# 1. Create a static group for the 'lottery winners' and save the ID number
# 2. Design a smart group with the pool of eligible computers (lottery players).
# 3. The criteria for #3 must exclude machines (or groups with 'not a member of') that you don't ever want to be eligible for the lottery.
# 4. The criteria for #3 must also exclude the new lottery static group as 'not a member of,' because they've already won the lottery.  They should not be allowed to win again.
# 5. Create API user with full read/write privileges on Jamf Pro Server Objects (no settings or actions).
# 6. Fill out your JSS URL, username, and password below, and set the actual group IDs.

jss_url="https://jss.acme.corp:443"
jss_api_user="apiuser"
jss_api_pass="apiuser"
SmartGroupID="99990"
StaticGroupID="99991"

# THIS ONE DOWNLOADS THE SMART GROUP
# Change the ID number of the Smart Group up above.
# Make sure your Smart Group excludes computers
# that you DON'T want to "win the lottery!"

curl -H "Accept: Application/xml" -X GET --user "$jss_api_user":"$jss_api_pass" "$jss_url"/JSSResource/computergroups/id/$SmartGroupID | xmllint --xpath '//computers/computer/id' - > ~/XML_not-lottery.txt

cat ~/XML_not-lottery.txt | sed -e 's_<id>__g' | sed -e 's_<\/id>_\
_g' > ~/compid_not-lottery.txt

count=$(wc -l ~/compid_not-lottery.txt | awk '{ print $1 }' )

echo "Number of computers is: $count"


# RANDOM NUMBER GENERATOR
# If you want to do more than 10 computers,
# Change loop=10 to something higher, like loop=50

luckyWinners=($(/usr/bin/awk -v loop=10 -v range=$count 'BEGIN { 
	srand()
	do {
		num = 1 + int(rand() * range)
		if (!(num in prev)) {
			print num
			prev[num] = 1
			count++
		}
	} while (count<loop)
}'))

# echo "The lucky winners are: ${luckyWinners[@]}"


for num in ${luckyWinners[@]}
do

thisLine=$(sed "${num}q;d" ~/compid_not-lottery.txt)
echo "Adding computer ID: $thisLine to the lottery!"

# THIS ONE PUTS COMPUTERS IN THE STATIC GROUP
# Change the $StaticGroupID above to the ID number
# of the Static Group you created in the JSS

curl -H "Content-Type: text/xml" -X PUT --user "$jss_api_user":"$jss_api_pass" $jss_url/JSSResource/computergroups/id/$StaticGroupID --data "<computer_group><computer_additions><computer><id>$thisLine</id></computer></computer_additions></computer_group>"

echo " "
echo " "
done
	


