#!/bin/bash
if [ -z $1 ]
then
 echo You must pass both a user and a token to start the agent properly
 echo $0 cz-user cz-token
 exit 1
fi

master=`kubectl cluster-info | awk '/master/ {print $6}'  | cut -d / -f 3`

sed -i '' -e "s/NOUSER/${1}/" -e "s/NOTOKEN/${2}/" -e "s/MASTER/${master}/" agent.yml
