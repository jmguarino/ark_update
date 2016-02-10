#!/bin/bash
# Ark Server update script

echo -e "\n---Starting ark update $(date)" >> /var/log/arkupdate.log

# Perform weekly backup on Monday
day=$(date +%a)

if [ "$day" == "Mon" ]; then
       	echo -e "Starting weekly backup\n"
	mv /home/soc/ark_weekly.tgz /home/soc/ark_weekly.tgz.backup
       	tar cvfz /home/soc/ark_weekly.tgz /home/steam/ark/ShooterGame/Saved
       	if [ -e /home/soc/ark_weekly.tgz ] 
	then 
	  echo -e "Weekly backup completed-$(date)" >> /var/log/arkupdate.log
	  rm -f /home/soc/ark_weekly.tgz.backup
	else
	  echo -e "Weekly backup FAILED-$(date)" >> /var/log/arkupdate.log
       	fi
fi

# Kill Ark main server processes if running
sgsPID=$(pgrep ShooterGameServ)
asPID=$(pgrep arkstart)

if pgrep "ShooterGameServ" > /dev/null 
then
	echo -e "Waiting for ShooterGameServer (pid $sgsPID) to shutdown...\n"
	kill -HUP $sgsPID 
	while pgrep ShooterGameServ > /dev/null; do sleep 1; done
	if pgrep "arkstart" > /dev/null
	then	
		kill -HUP $asPID
		while pgrep arkstart > /dev/null; do sleep 1; done
	fi
	echo -e "Ark processes terminated. Running server update...\n"
fi

# Update ARK server
/home/steam/steamcmd/steamcmd.sh +runscript /home/steam/bin/update_ark_server &
sleep 10

if pgrep "steamcmd" > /dev/null
then
	echo -e "steamcmd Ark update script started">> /var/log/arkupdate.log
	# Once update is done start server
	while pgrep steamcmd > /dev/null; do sleep 10; done
	echo -e "Ark update done, starting Ark server"
	/home/soc/bin/arkstart &
	echo -e "Update successful and server started- $(date)" >> /var/log/arkupdate.log
else
	echo -e "steamcmd Ark update script NOT started">> /var/log/arkupdate.log
	/home/soc/bin/arkstart &
	echo -e "Update failed but Ark process is again running">>/var/log/arkupdate.log
fi
