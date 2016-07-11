#!/bin/bash
if [ -z $1 ]
then
 echo You must pass both a user and a token to start the agent properly
 echo $0 cz-user cz-token target_ip
 exit 1
fi

if [ ! -z ${3} ]
cat agent.yml | sed '' -e "s/NOUSER/${1}/" -e "s/NOTOKEN/${2}/" -e "s/MASTER/${}/" > ${3}-agent.yml

scp ${3}-agent.yaml core@${3}:
ssh core@${3} "sudo cp ${3}-agent.yaml /etc/kubernetes/manifests/"
