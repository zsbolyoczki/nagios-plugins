#!/bin/bash

#
# checks local disk space utilization
#
# only returns the disk with the least free space if it is below the WARNING or CRITICAL treshold percentage
# or an "All disks are OK" message
#
# the original nagios plugin returns all disks statuses regardless of their real status
#


if [ $# -ne 2 ]; then

	echo "Unknown: invalid number of parameters"
	exit 3

else

	df -lh --output='target,used,size,pcent' | egrep "^/" | sed 's/%//g' | sort -n -k4 | tail -n1 | awk -v W=${1} -v C=${2} '{ if ($NF>C) { print "CRITICAL: "$1,$NF"% ("$2"/"$3")"; RC=2 } else if ($NF>W) { print "Warning: "$1,$NF"% ("$2"/"$3")"; RC=1 } else { print "All disks are OK"; RC=0;}} END {exit RC}'

fi
