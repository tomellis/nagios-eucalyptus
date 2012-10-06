#!/bin/bash

# Nagios plugin to check memory consumption
# Excludes Swap and Caches so only the real memory consumption is considered

. /usr/lib64/nagios/plugins/utils.sh

# set default values for the thresholds
WARN=90
CRIT=95

while getopts "c:w:h" ARG; do
        case $ARG in
                w) WARN=$OPTARG;;
                c) CRIT=$OPTARG;;
                h) echo "Usage: $0 -w <warning threshold> -c <critical threshold>"; exit;;
        esac
done

MEM_TOTAL=`free | fgrep "Mem:" | awk '{print $2}'`;
MEM_USED=`free | fgrep "/+ buffers/cache" | awk '{print $3}'`;

PERCENTAGE=$(($MEM_USED*100/$MEM_TOTAL))
echo "${PERCENTAGE}% ($((($MEM_USED)/1024)) of $((MEM_TOTAL/1024)) MB) used";

if [ $PERCENTAGE -gt $CRIT ]; then
        exit $STATE_CRITICAL;
elif [ $PERCENTAGE -gt $WARN ]; then
        exit $STATE_WARNING;
else
        exit $STATE_OK;
fi

