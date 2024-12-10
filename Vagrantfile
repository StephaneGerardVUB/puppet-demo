# -*- mode: ruby -*-
# vi: set ft=ruby :

# Main source of inspiration: https://github.com/lbernail/vagrant-puppet/tree/master

# Check that required vagrant plugins are installed
["vagrant-hosts", "vagrant-libvirt"].each do |plugin|
  abort "Please install the #{plugin} Vagrant plugin with 'vagrant pluging install #{plugin}'" unless Vagrant.has_plugin?("#{plugin}")
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

SUBNET="192.168.128"
DOMAIN="vm.local"

MASTERNAME="puppetmaster"
MASTERIP="#{SUBNET}.2"

DBNAME="puppetdb"
DBIP="#{SUBNET}.3"

REPORTSNAME="puppetreports"
REPORTSIP="#{SUBNET}.4"

AGENTS=["node1"]


Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.provider :libvirt do |libvirt|
    libvirt.qemu_use_session = false
    libvirt.memory = 4096
    libvirt.cpus = 2
  end

  config.vm.define :puppetmaster do |pm|
    pm.vm.box = "eurolinux-vagrant/rocky-8"
    pm.vm.box_version = "8.10.5"
    pm.vm.hostname = "#{MASTERNAME}.#{DOMAIN}"
    pm.vm.network :private_network, ip: "#{MASTERIP}" 
    pm.vm.network :forwarded_port, guest: 5000, host: 5000
    pm.vm.provision :hosts, :sync_hosts => true
    dir = File.expand_path("..", __FILE__)
    puts "DIR: #{dir}"
    pm.vm.provision :shell, :path => File.join(dir, "vagrant_pm_install.sh")
  end

  # config.vm.define :puppetdb do |pm|
  #   pm.vm.box = "eurolinux-vagrant/rocky-8"
  #   config.vm.box_version = "8.10.5"
  #   pm.vm.hostname = "#{DBNAME}.#{DOMAIN}"
  #   pm.vm.network :private_network, ip: "#{DBIP}" 
  #   pm.vm.provision :hosts, :sync_hosts => true
  #   pm.vm.provision :shell, :path => "install_agent_centos.sh"
  # end

  # config.vm.define :puppetreports do |pm|
  #   pm.vm.box = "eurolinux-vagrant/rocky-8"
  #   config.vm.box_version = "8.10.5"
  #   pm.vm.hostname = "#{REPORTSNAME}.#{DOMAIN}"
  #   pm.vm.network :private_network, ip: "#{REPORTSIP}" 
  #   pm.vm.network :forwarded_port, guest: 5000, host: 5001
  #   pm.vm.provision :hosts, :sync_hosts => true
  #   pm.vm.provision :shell, :path => "install_agent_centos.sh"
  # end

  AGENTS.each_with_index do |agent,index|
    config.vm.define "#{agent}".to_sym do |ag|
        ag.vm.box = "eurolinux-vagrant/rocky-8"
        ag.vm.box_version = "8.10.5"
        ag.vm.hostname = "#{agent}.#{DOMAIN}"
        ag.vm.network :private_network, ip: "#{SUBNET}.#{index+10}"
        pm.vm.provision :hosts, :sync_hosts => true
        dir = File.expand_path("..", __FILE__)
        puts "DIR: #{dir}"
        ag.vm.provision :shell do |s|
          s.path = File.join(dir,"vagrant_client_install.sh")
          s.args = "#{MASTERNAME}.#{DOMAIN}"
        end
    end
  end  

end