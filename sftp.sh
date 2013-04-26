#!/bin/bash

HOST=$1
PORT=$2
USER=$3
PASS=$4
ACTION=$5

expect -c "
set timeout 5
spawn sftp -P ${PORT} ${USER}@${HOST}
expect \"*assword:\"
send ${PASS}\r
expect \"sftp>\"
send \"${ACTION}\r\"
expect \"sftp>\"
send \"exit\r\"
interact
"
