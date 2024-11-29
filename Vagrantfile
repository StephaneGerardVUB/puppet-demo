# -*- mode: ruby -*-
# vi: set ft=ruby :

# Main source of inspiration: https://github.com/lbernail/vagrant-puppet/tree/master

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

AGENTS=["websrv"]


#Generate a host file to share
$hostfiledata="127.0.0.1 localhost\n#{MASTERIP} #{MASTERNAME}.#{DOMAIN} #{MASTERNAME}"
$hostfiledata=$hostfiledata+"\n#{DBIP} #{DBNAME}.#{DOMAIN} #{DBNAME}"
$hostfiledata=$hostfiledata+"\n#{REPORTSIP} #{REPORTSNAME}.#{DOMAIN} #{REPORTSNAME}"
AGENTS.each_with_index do |agent,index|
  $hostfiledata=$hostfiledata+"\n#{SUBNET}.#{index+10} #{agent}.#{DOMAIN} #{agent}"
end

$set_host_file="cat <<EOF > /etc/hosts\n"+$hostfiledata+"\nEOF\n"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  
  config.vm.define :puppetmaster do |pm|
    pm.vm.box = "eurolinux-vagrant/rocky-8"
    config.vm.box_version = "8.10.5"
    pm.vm.hostname = "#{MASTERNAME}.#{DOMAIN}"
    pm.vm.network :private_network, ip: "#{MASTERIP}" 
    pm.vm.network :forwarded_port, guest: 5000, host: 5000
    pm.vm.provision :shell, :inline => $set_host_file
    pm.vm.provision :shell, :path => "pm_intall.sh"
  end

  # config.vm.define :puppetdb do |pm|
  #   pm.vm.box = "eurolinux-vagrant/rocky-8"
  #   config.vm.box_version = "8.10.5"
  #   pm.vm.hostname = "#{DBNAME}.#{DOMAIN}"
  #   pm.vm.network :private_network, ip: "#{DBIP}" 
  #   pm.vm.provision :shell, :inline => $set_host_file
  #   pm.vm.provision :shell, :path => "install_agent_centos.sh"
  # end

  # config.vm.define :puppetreports do |pm|
  #   pm.vm.box = "eurolinux-vagrant/rocky-8"
  #   config.vm.box_version = "8.10.5"
  #   pm.vm.hostname = "#{REPORTSNAME}.#{DOMAIN}"
  #   pm.vm.network :private_network, ip: "#{REPORTSIP}" 
  #   pm.vm.network :forwarded_port, guest: 5000, host: 5001
  #   pm.vm.provision :shell, :inline => $set_host_file
  #   pm.vm.provision :shell, :path => "install_agent_centos.sh"
  # end

  # AGENTS.each_with_index do |agent,index|
  #   config.vm.define "#{agent}".to_sym do |ag|
  #       ag.vm.box = "boxcutter/centos72"
  #       ag.vm.hostname = "#{agent}.#{DOMAIN}"
  #       ag.vm.network :private_network, ip: "#{SUBNET}.#{index+10}"
  #       ag.vm.provision :shell, :inline => $set_host_file
  #       ag.vm.provision :shell, :path => "install_agent_centos.sh"
  #   end
  # end  

end