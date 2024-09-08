Sample Vagrantfile 
===================

This is a guide to install VM instances for Burrito in vagrant environment.

Copy this directory to your test directory.

For example, if you test directory is mytest_lab,::

   # cd $HOME
   # mkdir -p mytest_lab
   # cp -a burrito_tmpl/* mytest_lab/

Go to your test directory and edit Vagrantfile until you see 
'do not edit' comment.::

   # cd mytest_lab
   # vi Vagrantfile
   # -*- mode: ruby -*-
   # vi: set ft=ruby :
   
   Control = {
     'num' => 3,
     'name_prefix' => 'control',
     'cpus' => 8,
     'memory' => 16,
     'disk' => 100
   }
   Compute = {
     'num' => 2,
     'name_prefix' => 'compute',
     'cpus' => 8,
     'memory' => 8,
     'disk' => 100
   }
   Storage = {
     'num' => 3,
     'name_prefix' => 'storage',
     'cpus' => 8,
     'memory' => 8,
     'disk' => 100
   }
   
   OSD_SIZE = '50GB'
   
   IP = 21  # The last octet of the IP address to begin 
   
   #################################################
   ### Do not edit below if you are not an expert.
   #################################################

Run vagrant.::

   # vagrant up

And see vagrant status.::

   # vagrant status
   Current machine states:
   
   control1                  running (libvirt)
   control2                  running (libvirt)
   control3                  running (libvirt)
   compute1                  running (libvirt)
   compute2                  running (libvirt)
   storage1                  running (libvirt)
   storage2                  running (libvirt)
   storage3                  running (libvirt)

