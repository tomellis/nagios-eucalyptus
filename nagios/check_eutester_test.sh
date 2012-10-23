#! /bin/sh
#
# Simple Nagios plugin to check the results of Eutesters 
# instancetest.py testcase.
#
# Authors: Olivier Renault <olivier.renault@eucalyptus.com>
#          Tom Ellis <tom.ellis@eucalyptus.com>

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0.0"

FILE="/tmp/results/test-BasicInstanceChecks-result.txt"

if [ -f  $PROGPATH/utils.sh ];then
	. $PROGPATH/utils.sh
else
        STATE_OK=0
        STATE_WARNING=1
        STATE_CRITICAL=2
fi

print_help() {
	print_revision $PROGNAME $REVISION
	echo ""
	echo "This plugin checks for results from eutester instancetest.py testcase"
        echo "The results file this script checks can have 2 values, OK or FAIL"
	echo "If the file is not here WARNING will be triggered"
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
                if [ -f $FILE ] && [ ! -z $FILE ]; then
			if [ `grep PASS $FILE` ];then
				echo "OK: Eutester passed"
				exit $STATE_OK
			elif [ `grep FAIL $FILE` ];then
				echo "CRITICAL: Eutester failed"
				exit $STATE_CRITICAL
                        else
                                echo "CRITICAL: Invalid result returned"
                                exit $STATE_CRITICAL
			fi
                else
			echo "WARNING - Results File not found"
			exit $STATE_WARNING
		fi
		;;
esac
