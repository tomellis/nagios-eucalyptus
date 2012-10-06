# nagios-eucalyptus

## Overview

This are some simple Nagios check script to monitor your Eucalyptus cloud

## Prerequisite

The scripts are using Nagios Remote Plugin Executor ( NRPE ) to communicate in between Nagios server and host. 

## Installation 

### Check NRPE is working

You can check NRPE is working by running check_nrpe from your nagios server. If it is working, you should get the version of NRPE agent on your client. 
<pre><code>
/your/nagios/plugins/directory/check_nrpe -H <IP of your Clients>
</code></pre>


