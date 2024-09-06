# -*- mode: ruby -*-
# vi: set ft=ruby :

Control = {
  'num' => 1,
  'name_prefix' => 'control',
  'cpus' => 4,
  'memory' => 8,
  'disk' => 50
}
Compute = {
  'num' => 1,
  'name_prefix' => 'compute',
  'cpus' => 4,
  'memory' => 4,
  'disk' => 50
}
Storage = {
  'num' => 1,
  'name_prefix' => 'storage',
  'cpus' => 4,
  'memory' => 4,
  'disk' => 50
}

OSD_SIZE = '50GB'

USERNAME = 'clex'
USERPW = '<clex password>'

IP = <Put the last octet of ip> 

#################################################
### Do not edit below if you are not an expert.
#################################################

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'
BOX = 'iorchard/burrito-8.10'
NET = {
  'mgmt' => '192.168.20.',
  'overlay' => '192.168.30.',
  'provider' => '10.10.40.',
  'storage' => '192.168.50.'
}
File.write("etchosts", "127.0.0.1 localhost\n")
s_etchostsall = "127.0.0.1 localhost\n"
(1..Control['num']).each do |i|
  n = IP+(i-1)
  s_etchostsall += NET['mgmt'] + "#{n} " + Control['name_prefix'] + "#{i}\n"
end
(1..Compute['num']).each do |i|
  n = IP+Control['num']+(i-1)
  s_etchostsall += NET['mgmt'] + "#{n} " + Compute['name_prefix'] + "#{i}\n"
end
(1..Storage['num']).each do |i|
  n = IP+Control['num']+Compute['num']+(i-1)
  s_etchostsall += NET['mgmt'] + "#{n} " + Storage['name_prefix'] + "#{i}\n"
end
File.write("etchostsall", s_etchostsall)

$script = <<-'SHELL'
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' \
  /etc/ssh/sshd_config
systemctl restart sshd.service
sudo mv hosts /etc/hosts
growpart /dev/sda 1
xfs_growfs /dev/sda1
reboot
SHELL

$control_script = <<-'SHELL'
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' \
  /etc/ssh/sshd_config
systemctl restart sshd.service
sudo mv hosts /etc/hosts
growpart /dev/sda 1
xfs_growfs /dev/sda1
[ -f /tmp/i_am_the_first_controller ] && \
  echo "192.168.121.1:/srv/iso /vagrant nfs ro 0 0" >> /etc/fstab || true
reboot
SHELL

Vagrant.configure("2") do |config|
  config.vm.synced_folder "/srv/iso/", "/vagrant",
    type: "nfs", mount_options: ['ro']
  (1..Control['num']).each do |i|
    n = IP+(i-1)
    config.vm.define Control['name_prefix']+"#{i}" do |cfg|
      cfg.vm.box = BOX
      cfg.ssh.username = USERNAME
      cfg.ssh.password = USERPW
      cfg.vm.provider "libvirt" do |vb|
        vb.cpus = Control['cpus']
        vb.memory = Control['memory'] * 1024
        vb.management_network_name = "service"
        vb.storage_pool_name = "vagrant"
        vb.machine_virtual_size = Control['disk']
        vb.disk_bus = 'scsi'
        vb.disk_device = 'sda'
      end
      cfg.vm.host_name = Control['name_prefix'] + "#{i}"
      cfg.vm.network "private_network", ip: NET['mgmt'] + "#{n}",
        libvirt__network_name: "mgmt",
        libvirt__forward_mode: "none",
        libvirt__dhcp_enabled: "false"
      cfg.vm.network "private_network", ip: NET['overlay'] + "#{n}",
        libvirt__network_name: "tenant",
        libvirt__forward_mode: "none",
        libvirt__dhcp_enabled: "false"
      cfg.vm.network "private_network", ip: NET['provider'] + "#{n}",
        libvirt__network_name: "provider",
        libvirt__dhcp_enabled: "false"
      cfg.vm.network "private_network", ip: NET['storage'] + "#{n}",
        libvirt__network_name: "storage",
        libvirt__forward_mode: "none",
        libvirt__dhcp_enabled: "false"
      cfg.vm.network "forwarded_port", guest: 22, host: 60000+n,
        host_ip: "127.0.0.1"
      cfg.vm.provision "file", source: "ifcfg-eth3",
        destination: "/etc/sysconfig/network-scripts/ifcfg-eth3"
      if i == 1
        cfg.vm.provision "shell", inline: "touch /tmp/i_am_the_first_controller"
        cfg.vm.provision "file", source: "etchostsall", destination: "hosts"
      else
        cfg.vm.provision "file", source: "etchosts", destination: "hosts"
      end
      cfg.vm.provision "shell", inline: $control_script
    end
  end

  (1..Compute['num']).each do |i|
    n = (IP+Control['num'])+(i-1)
    config.vm.define Compute['name_prefix']+"#{i}" do |cfg|
      cfg.vm.box = BOX
      cfg.ssh.username = USERNAME
      cfg.ssh.password = USERPW
      cfg.vm.provider "libvirt" do |vb|
        vb.cpus = Compute['cpus']
        vb.memory = Compute['memory']*1024
        vb.nested = true
        vb.cpu_mode = "host-passthrough"
        vb.management_network_name = "service"
        vb.storage_pool_name = "vagrant"
        vb.machine_virtual_size = Compute['disk']
        vb.disk_bus = 'scsi'
        vb.disk_device = 'sda'
      end
      cfg.vm.host_name = Compute['name_prefix'] + "#{i}"
      cfg.vm.network "private_network", ip: NET['mgmt'] + "#{n}",
        libvirt__network_name: "mgmt"
      cfg.vm.network "private_network", ip: NET['overlay'] + "#{n}",
        libvirt__network_name: "tenant"
      cfg.vm.network "private_network", ip: NET['provider'] + "#{n}",
        libvirt__network_name: "provider"
      cfg.vm.network "private_network", ip: NET['storage'] + "#{n}",
        libvirt__network_name: "storage"
      cfg.vm.network "forwarded_port", guest: 22, host: 60000+n,
        host_ip: "127.0.0.1"
      cfg.vm.provision "file", source: "ifcfg-eth3",
        destination: "/etc/sysconfig/network-scripts/ifcfg-eth3"
      cfg.vm.provision "file", source: "etchosts",
        destination: "hosts"
      cfg.vm.provision "shell", inline: $script
    end
  end

  (1..Storage['num']).each do |i|
    n = IP+Control['num']+Compute['num']+(i-1)
    config.vm.define Storage['name_prefix']+"#{i}" do |cfg|
      cfg.vm.box = BOX
      cfg.ssh.username = USERNAME
      cfg.ssh.password = USERPW
      cfg.vm.provider "libvirt" do |vb|
        vb.cpus = Storage['cpus']
        vb.memory = Storage['memory']*1024
        vb.management_network_name = "service"
        vb.storage :file, :device => 'sdb', :size => OSD_SIZE, :bus => 'scsi'
        vb.storage :file, :device => 'sdc', :size => OSD_SIZE, :bus => 'scsi'
        vb.storage :file, :device => 'sdd', :size => OSD_SIZE, :bus => 'scsi'
        vb.storage_pool_name = "vagrant"
        vb.machine_virtual_size = 100
        vb.disk_bus = 'scsi'
        vb.disk_device = 'sda'
      end
      cfg.vm.host_name = Storage['name_prefix'] + "#{i}"
      cfg.vm.network "private_network", ip: NET['mgmt'] + "#{n}",
        libvirt__network_name: "mgmt"
      cfg.vm.network "private_network", ip: NET['overlay'] + "#{n}",
        libvirt__network_name: "tenant"
      cfg.vm.network "private_network", ip: NET['provider'] + "#{n}",
        libvirt__network_name: "provider"
      cfg.vm.network "private_network", ip: NET['storage'] + "#{n}",
        libvirt__network_name: "storage",
        libvirt__dhcp_enabled: "false"
      cfg.vm.network "forwarded_port", guest: 22, host: 60000+n,
        host_ip: "127.0.0.1"
      cfg.vm.provision "file", source: "ceph-ifcfg-eth2",
        destination: "/etc/sysconfig/network-scripts/ifcfg-eth2"
      cfg.vm.provision "file", source: "ifcfg-eth3",
        destination: "/etc/sysconfig/network-scripts/ifcfg-eth3"
      cfg.vm.provision "file", source: "etchosts",
        destination: "hosts"
      cfg.vm.provision "shell", inline: $script
    end
  end
end

