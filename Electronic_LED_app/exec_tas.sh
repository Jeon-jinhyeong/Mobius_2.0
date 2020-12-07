#!/bin/bash

HOST="202.30.30.121"
USER="wjs123"
PASS="wjs123"

cd /home/pi/node/thyme;nohup node thyme.js 1> /dev/null 2>&1 &

MAC=`sudo cat /sys/class/net/eth0/address | sed s/":"/""/g | tr '[a-z]' '[A-Z]'`
WALLET=`mysql -h 202.30.30.121 -D mobiusdb -u root -p'mysql!!' -e "select (wallet) from users WHERE macaddr='$MAC'" -B | tail -n 1`
echo $MAC
echo $WALLET


expect -c "
spawn sftp ${USER}@${HOST}
expect \"Are you sure you want to continue connecting (yes/no)?\"
send \"yes\r\"
expect \"password: \"
send \"${PASS}\r\"
expect \"sftp>\"
send \"mget app_co2.js /home/pi/node/tas_co2/app.js\r\"
expect \"sftp>\"
send \"mget app_led.js /home/pi/node/tas_led/app.js\r\"
expect \"sftp>\"
send \"bye\r\"
expect \"#\"
"

sed -i 261a\\"var users=$WALLET" /home/pi/node/tas_co2/app.js

cd /home/pi/node/tas_co2;nohup node app.js 1> /dev/null 2>&1 &
cd /home/pi/node/tas_led;nohup node app.js 1> /dev/null 2>&1 &

sleep 2

rm -rf /home/pi/.ssh
rm -rf /home/pi/node/tas_co2/app.js
rm -rf /home/pi/node/tas_led/app.js
rm -rf /home/pi/exec_tas.sh
