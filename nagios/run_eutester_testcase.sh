#!/bin/bash
# 
# This script runs Eutester's basic instance test testcase and 
# outputs the result in /tmp/results for the nagios check script 
# to parse. Call this script from cron every hour to test your
# cloud.
#
# Authors: Olivier Renault <olivier.renault@eucalyptus.com>
#          Tom Ellis <tom.ellis@eucalyptus.com>

# Replace these variables as necessary
CREDPATH='/root/.eucarc/'
TEST='BasicInstanceChecks'
EMI='emi-AE6A355B'
TESTCASE='/root/eutester/testcases/cloud_user/instances/instancetest.py'

# Run the test
python $TESTCASE --credpath=$CREDPATH --tests $TEST --emi $EMI --nagios
