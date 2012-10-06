# nagios-eucalyptus

## Overview

This are some simple Nagios check script to monitor your Eucalyptus cloud

## Prerequisite

The scripts are using Nagios Remote Plugin Executor / NRPE (http://exchange.nagios.org/directory/Addons/Monitoring-Agents/NRPE--2D-Nagios-Remote-Plugin-Executor/details) to communicate in between Nagios server and host. 

## Installation 

### Check NRPE is working

You can check NRPE is working by running check_nrpe from your nagios server. The following command, should return the version of NRPE agent on your client. 
<pre><code>
/your/nagios/plugins/directory/check_nrpe -H < IP of your Clients > 
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

Then you can reference it like the following. This is my services.cfg

## Usage

### Check Loopback

This will check how many loopback devices are available. It should be used on the Storage Controller / Node Controller. 

<pre><code>
define service{
        use                             generic-service         ; Name of service template to use
        hostgroup_name                  Eucalyptus Servers
        service_description             Check loopback device availability
        check_command                   check_nrpe_command!check_loopback
}
</code></pre>

### Check libvirtd

On Xen / KVM based Cloud, you should check that libvirt daemon is running. 

<pre><code>
define service{
        use                             local-service         ; Name of service template to use
        hostgroup_name                  cloud3-nc
        service_description             Check libvirtd service
        check_command                   check_nrpe_command!check_libvirtd
}
</code></pre>


