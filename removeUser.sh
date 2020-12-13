#!/bin/bash

#put url of jamf pro here
jssURL=""

#put credentials here for a jamf user that can change static user group assignments
jssUser=""
jssPassword=""

#put usernames here - multiple entries can be added but they must each be surrounded by quotes with a space between them - no commas
restrictedUser=("user1" "user2" "user3")

#function to remove user 
removeUser(){

#change [usergroupnumber] to the ID of the static group you wish to add the users to
curl -s -u $jssUser:$jssPassword  ${jssURL}/JSSResource/usergroups/id/[usergroupnumber] -H "Content-Type: application/xml" -d "<user_group><user_deletions><user><username>${user}</username></user></user_deletions></user_group>" -X PUT > /tmp/temp.txt 
conflictDetected=$(grep -c 'Unable to update the database' /tmp/temp.txt )
}

#removes the user from the static user group
for user in ${restrictedUser[@]}; do
	removeUser
	while [ "$conflictDetected" -gt 0 ]; do
	echo "$(date -u) A database error occurred. ${user} was not removed from the group. Trying again in a few seconds."
	sleep 15
	removeUser
	done
	echo "$(date -u) ${user} was removed from the group." >> /var/log/scheduler.log
done
