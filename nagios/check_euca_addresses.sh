#! /bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0.0"

. $PROGPATH/utils.sh

# Eucalyptus Admin Credentials
export EC2_URL=http://109.200.204.4:8773/services/Eucalyptus
export S3_URL=http://109.200.204.6:8773/services/Walrus
export EC2_ACCESS_KEY='JCANTVFQFQS1MMKWMR10H'
export EC2_SECRET_KEY='UNkpne54iwiqAZ2UEwwo5ohdgs3IIEteIF5ozeq0'

print_usage() {
	echo "Usage: $PROGNAME [warning-percent] [critical-percent]"
}

print_help() {
	print_revision $PROGNAME $REVISION
	echo ""
	print_usage
	echo ""
	echo "This plugin checks for Eucalyptus Public IP Address Availablity."
	echo ""
	support
	exit 0
}

case "$1" in
	--help)
		print_help
		exit 0
		;;
	-h)
		print_help
		exit 0
		;;
	--version)
   	print_revision $PROGNAME $REVISION
		exit 0
		;;
	-V)
		print_revision $PROGNAME $REVISION
		exit 0
		;;
	*)
                ADDR_WARN=$1
                ADDR_CRIT=$2
		ADDR_TOTAL=$(euca-describe-addresses | wc -l)
		ADDR_AVAIL=$(euca-describe-addresses | grep 'nobody' | wc -l)
		ADDR_USED=$(( ${ADDR_TOTAL} -${ADDR_AVAIL} ))
		ADDR_USED_PERCENT=$(( $((${ADDR_USED} * 100)) / ${ADDR_TOTAL} ))
		ADDR_AVAIL_PERCENT=$(( $((${ADDR_AVAIL} * 100)) / ${ADDR_TOTAL} ))

		if [ ${ADDR_USED_PERCENT} -lt ${ADDR_WARN} ]; then
			echo "OK: Addresses used = ${ADDR_USED_PERCENT}% (${ADDR_USED}) | Addresses Available = ${ADDR_AVAIL_PERCENT}% (${ADDR_AVAIL}); Total Addresses = ${ADDR_TOTAL}"
			exit 0
                elif [ ${ADDR_USED_PERCENT} -ge ${ADDR_WARN} ] && [ ${ADDR_USED_PERCENT} -lt ${ADDR_CRIT} ]; then
			echo "WARNING: Addresses used = ${ADDR_USED_PERCENT}% (${ADDR_USED}) | Addresses Available = ${ADDR_AVAIL_PERCENT}% (${ADDR_AVAIL}); Total Addresses = ${ADDR_TOTAL}"
			exit 1
		elif [ ${ADDR_USED_PERCENT} -ge ${ADDR_CRIT} ]; then
			echo "CRITICAL: Addresses Available < ${ADDR_CRIT}% | Addresses used = ${ADDR_USED_PERCENT}% (${ADDR_USED}) | Addresses Available = ${ADDR_AVAIL_PERCENT}% (${ADDR_AVAIL}); Total Addresses = ${ADDR_TOTAL}" 
			exit 2
		fi
		;;
esac
