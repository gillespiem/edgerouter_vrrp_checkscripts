#!/bin/bash

. /config/scripts/monitor-config

# start modifying config
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin

# increase priority
#Formerly 10 and 150
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete interfaces ethernet eth0 vrrp vrrp-group 66 priority                  
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces ethernet eth0 vrrp vrrp-group 66 priority $LOW_PRIORITY

# now commit the changes
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit

# finish configuring
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end

#HUP keepalived to enforce the new config                                                                                     
sleep 10s

killall -HUP keepalived
