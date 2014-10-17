#! /bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0.0"

. $PROGPATH/utils.sh


print_usage() {
	echo "Usage: $PROGNAME"
}

print_help() {
	print_revision $PROGNAME $REVISION
	echo ""
	print_usage
	echo ""
	echo "This plugin checks loopback devices availability ."
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
                LOOPBACK_WARN=$1
                LOOPBACK_CRIT=$2
		LOOPBACK_USED=`losetup -a | wc -l`
               LOOPBACK_AVAILABLE=`find /dev/ -maxdepth 1 -name 'loop[0-9]' -o -name 'loop[0-9][0-9]'| wc -l `
		if test $(( ${LOOPBACK_AVAILABLE} - ${LOOPBACK_USED} )) -gt ${LOOPBACK_WARN} ; then
			echo "LOOPBACK OK - available: ${LOOPBACK_AVAILABLE}"
			exit 0
                elif [ $(( ${LOOPBACK_AVAILABLE} - ${LOOPBACK_USED} )) -lt ${LOOPBACK_WARN} ] && [ $(( ${LOOPBACK_AVAILABLE} - ${LOOPBACK_USED} )) -gt ${LOOPBACK_CRIT} ]; then
			echo "WARNING - LOOPBACK AVAILABLE =  $(( ${LOOPBACK_AVAILABLE} - ${LOOPBACK_USED} ))"
			exit 1
		elif  test $(( ${LOOPBACK_AVAILABLE} - ${LOOPBACK_USED} )) -le ${LOOPBACK_CRIT} ; then
			echo "SENSOR CRITICAL - LOOPBACK AVAILABLE < ${LOOPBACK_CRIT}" 
			exit 2
		fi
		;;
esac
