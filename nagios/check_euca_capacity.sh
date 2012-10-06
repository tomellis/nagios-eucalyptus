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
	echo "This plugin checks for available cores in a Eucalyptus Cloud"
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
                CORES_WARN=$1
                CORES_CRIT=$2
		# We assume an m1.small is 1 cores
		CORES_TOTAL=$(euca-describe-availability-zones verbose  | awk '/m1.small/ {total += $6}END{ print total}')
		CORES_AVAIL=$(euca-describe-availability-zones verbose  | awk '/m1.small/ {total += $4}END{ print total}')
		CORES_USED=$(( ${CORES_TOTAL} -${CORES_AVAIL} ))
		CORES_USED_PERCENT=$(( $((${CORES_USED} * 100)) / ${CORES_TOTAL} ))
		CORES_AVAIL_PERCENT=$(( $((${CORES_AVAIL} * 100)) / ${CORES_TOTAL} ))

		if [ ${CORES_USED_PERCENT} -lt ${CORES_WARN} ]; then
			echo "OK: Cores used = ${CORES_USED_PERCENT}% (${CORES_USED}) | Cores Available = ${CORES_AVAIL_PERCENT}% (${CORES_AVAIL}); Total Cores = ${CORES_TOTAL}"
			exit 0
                elif [ ${CORES_USED_PERCENT} -ge ${CORES_WARN} ] && [ ${CORES_USED_PERCENT} -lt ${CORES_CRIT} ]; then
			echo "WARNING: Cores used = ${CORES_USED_PERCENT}% (${CORES_USED}) | Cores Available = ${CORES_AVAIL_PERCENT}% (${CORES_AVAIL}); Total Cores = ${CORES_TOTAL}"
			exit 1
		elif [ ${CORES_USED_PERCENT} -ge ${CORES_CRIT} ]; then
			echo "CRITICAL: Cores Available < ${CORES_CRIT}% | Cores used = ${CORES_USED_PERCENT}% (${CORES_USED}) | Cores Available = ${CORES_AVAIL_PERCENT}% (${CORES_AVAIL}); Total Cores = ${CORES_TOTAL}" 
			exit 2
		fi
		;;
esac
