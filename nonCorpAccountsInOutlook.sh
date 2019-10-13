#!/bin/zsh

# Set internal field separator to "newline" - this is important for the "numCorpAccounts" section.
IFS=$'\n'

# Finds the user's Office directory.
# NOTE: this assumes only ONE user per computer with Outlook configured.
userOfficeFolder=$(find /Users -type d -maxdepth 4 -name 'UBF8T346G9.Office' | head -1)

# Preset location of the Outlook Mail Accounts folder.
outlookMailAccounts="Outlook/Outlook 15 Profiles/Main Profile/Data/Mail Accounts"

# CHANGE THIS to match your company domain
corpAccountDomain="@acme.com"

# Number of total accounts in Outlook
numOutlookAccounts=$(grep -lR '@' "$userOfficeFolder/$outlookMailAccounts" | grep -v ".DS_Store" | wc -l | tr -d '[:blank:]')

# Number of accounts matching the corporate domain
numCorpAccounts=$(for i in $(grep -lR '@' "$userOfficeFolder/$outlookMailAccounts" | grep -v ".DS_Store"); do grep -l "$corpAccountDomain" "$i"; done | wc -l | tr -d '[:blank:]')

# Simple math (subtract total from corp = non corp)
numNonCorpAccounts=$(echo "$numOutlookAccounts - $numCorpAccounts" | bc)

# Output the result
echo "<result>$numNonCorpAccounts</result>"

exit 0
