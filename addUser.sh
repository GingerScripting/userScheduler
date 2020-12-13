#!/bin/bash

#put url of jamf pro here
jssURL=""

#put credentials here for a jamf user that can change static user group assignments
jssUser=""
jssPassword=""

#put usernames here - multiple entries can be added but they must each be surrounded by quotes with a space between them - no commas
restrictedUser=("user1" "user2" "user3")

#change [usergroupnumber] to the ID of the static group you wish to add the users to
addUser(){
conflictDetected=$(curl -s -u $jssUser:$jssPassword  ${jssURL}/JSSResource/usergroups/id/[usergroupnumber] -H "Content-Type: application/xml" -d "<user_group><user_additions><user><username>${user}</username></user></user_additions></user_group>" -X PUT 2>&1 | grep -c 'Unable to update the database') 
}

#adds the user to the static user group and does a 15 second sleep if there is an error before trying again
for user in ${restrictedUser[@]}; do
	addUser
	while [ "$conflictDetected" -gt 0 ]; do
	echo "$(date -u) A database error occurred. ${user} was not added to the group. Trying again in a few seconds." >> /var/log/scheduler.log
	sleep 15
	addUser
	done
	echo "$(date -u) ${user} was added to the group." >> /var/log/scheduler.log
done
