# nagios-eucalyptus

## Overview

This are some simple Nagios check script to monitor your Eucalyptus cloud. You should probably also monitor all the normal components of a Linux host : CPU, RAM, Disk, SWAP, IO, ...


## Prerequisite

The scripts are using Nagios Remote Plugin Executor / NRPE (http://exchange.nagios.org/directory/Addons/Monitoring-Agents/NRPE--2D-Nagios-Remote-Plugin-Executor/details) to communicate in between Nagios server and host. 

## Installation 

### Check NRPE is working

You can check NRPE is working by running check_nrpe from your nagios server. The following command, should return the version of NRPE agent on your client. 
<pre><code>
/your/nagios/plugins/directory/check_nrpe -H Client_IP
NRPE v2.12

</code></pre>



### Add the plugins on each nodes

Copy the content of the nrpe plugins directory to your nagios plugin directory. All scripts must be executable. 

You need to amend your nrpe configuration to declare your new scripts. 
<pre><code>
# Check loop takes two arguments. It will generate a warning if you've got less than 10 and an error for less than 5.
command[check_loopback]=/path/to/your/nagios/plugins/check_loop.sh  10 5

# for Ubuntu 
command[check_libvirtd_ubuntu]=/path/to/your/nagios/plugins/check_upstart_status.pl -j libvirt-bin

# for CentOS
command[check_libvirtd_centos]=/path/to/your/nagios/plugins/check_exit_status.pl -s /etc/init.d/libvirtd

</code></pre>
Check Upstart http://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/Check-Upstart-Job-Status/details

Check Exit Status http://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/Check--2Fetc-2Finit-2Ed-script-status/details

## Add your check in Nagios

###  Configure your commands

Edit your commands.cfg and add the following

<pre><code>
define  command {
        command_name    check_nrpe_command
        command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}

define  command {
        command_name    check_nrpe_command_args
        command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -a $ARG2$
}

define command {
        command_name    check_euca_addresses
        command_line    $USER1$/check_euca_addresses.sh $ARG1$ $ARG2$
}

define command {
        command_name    check_tcp_service
        command_line    $USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$
}

define command {
        command_name    check_euca_capacity
        command_line    $USER1$/check_euca_capacity.sh $ARG1$ $ARG2$
}
define command {
        command_name    check_basic_test
        command_line    $USER1$/euca_basic_test.sh
}
</code></pre>

### Check Eucalyptus cloud service

The cloud service is running on your Cloud Controller, Storage Controller, Walrus. 

<pre><code>
define service {
        use                             local-service         ; Name of service template to use
        hostgroup_name                  Cloud Controller, Walrus, Storage Controller
        service_description             Eucalyptus-Cloud Service TCP Listen
        check_command                   check_tcp!8773
}

</code></pre>

### Check Eucalyptus cluster controller service

The cluster controller service ( eucalyptus-cc ) is running on your cluster Controller

<pre><code>
define service {
        use                             local-service         ; Name of service template to use
        hostgroup_name                  Cluster Controller
        service_description             Eucalyptus CC Service TCP Listen
        check_command                   check_tcp!8774
}

</code></pre>

### Check Eucalyptus node controller service

The node controller service ( eucalyptus-nc ) is running on all NCs

<pre><code>
define service {
        use                             local-service         ; Name of service template to use
        hostgroup_name                  Node Controller
        service_description             Eucalyptus-nc Service TCP Listen
        check_command                   check_tcp!8775
}

</code></pre>

### Check libvirtd

On Xen / KVM based Cloud, check that libvirt daemon is running on your Node Controllers

<pre><code>
define service {
        use                             local-service         ; Name of service template to use
        hostgroup_name                  Eucalyptus NC
        service_description             Check libvirtd service
        check_command                   check_nrpe_command!check_libvirtd
}

</code></pre>

### Check available public IP

This will check the amount of public IP available. It will issue a warning if 80% of IP are allocated and a critical error at 95%. 

It should run only from one node.

<pre><code>
define service{
        use                             local-service         ; Name of service template to use
        host_name                       localhost
        service_description             Eucalyptus IP Addresses
        check_command                   check_euca_addresses!80!95
}

</code></pre>

### Check cloud capacity

This will check the amount of core available on your cloud. It will issue a warning if 80% of your ressources are allocated and a critical error at 95%

It should run only from one node.

<pre><code>

define service{
        use                             local-service         ; Name of service template to use
        host_name                       localhost
        service_description             Eucalyptus Available Capacity
        check_command                   check_euca_capacity!80!95
}

</code></pre>


### Check Loopback

This will check how many loopback devices are available. It should be used on the Storage Controller / Node Controller. 

<pre><code>
define service{
        use                             local-service         ; Name of service template to use
        hostgroup_name                  Eucalyptus Servers
        service_description             Check loopback device availability
        check_command                   check_nrpe_command!check_loopback
}

</pre></code>

== How to extend monitoring.

You can also use eutester to extend Eucalyptus monitoring. Eutester will check that not only the components are available they can also be started / accessed. 

eutester : https://github.com/eucalyptus/eutester


