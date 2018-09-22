#!/bin/bash
# monitor.sh

. /config/scripts/monitor-config


if [ "$PPPOE_CONFIGURED" -eq 1 ];
then
	echo "PPPOE is configured"
	INTERFACE=`ifconfig pppoe0`
	if [ "$?" == 1 ]; then
		echo "This interface doesn't exist."
		exit;
	fi
	IP1=`echo $INTERFACE | egrep -o "(P-t-P:.*?) " | cut -d ' ' -f 1 | cut -d ':' -f 2`
else
	echo "PPPOE is not configured"
fi

# ping the hosts and record exit code (0 = success)
ping -W 1 -c 1 $IP1 &> /dev/null
UP1=$?

ping -W 1 -c 1 $IP2 &> /dev/null
UP2=$?

echo "$IP1 status: $UP1"
echo "$IP2 status : $UP2"

CURRENT_PRIORITY=$(cat /etc/keepalived/keepalived.conf|grep priority|cut -d ' ' -f 2 | head -n1)
echo "Initial priority: $CURRENT_PRIORITY"

echo "High priority: $HIGH_PRIORITY"
echo "Low priority: $LOW_PRIORITY"

# results
if [ "$UP1" == 0 ] || [ "$UP2" == 0 ] ; then
	echo "One or more hosts are up, set/hold full priority"
	
	if [ "$CURRENT_PRIORITY" -ne "$HIGH_PRIORITY" ] ; then
	      /config/scripts/increase-priority.sh
	fi
	PRIORITY_NOW=$(cat /etc/keepalived/keepalived.conf|grep priority|cut -d ' ' -f 2)
	echo "Priority is now: $PRIORITY_NOW"
else
	echo "Both hosts are down, set/hold low priority"
	if [ "$CURRENT_PRIORITY" -ne "$LOW_PRIORITY" ] ; then
        	/config/scripts/decrease-priority.sh
        fi
        PRIORITY_NOW=$(cat /etc/keepalived/keepalived.conf|grep priority|cut -d ' ' -f 2)
        echo "Priority is now: $PRIORITY_NOW"
fi
