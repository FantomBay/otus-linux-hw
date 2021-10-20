#!/bin/bash

if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
then
exit 0
fi
if [[ $(date +%u) > 5 ]]
then
exit 1
fi