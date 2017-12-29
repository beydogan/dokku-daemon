# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV["BOX_NAME"] || "bento/ubuntu-14.04"
BOX_MEMORY = ENV["BOX_MEMORY"] || "3000"
DOKKU_TAG = ENV["DOKKU_TAG"] || "v0.11.2"

Vagrant.configure(2) do |config|
  config.vm.box = BOX_NAME
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    # Ubuntu's Raring 64-bit cloud image is set to a 32-bit Ubuntu OS type by
    # default in Virtualbox and thus will not boot. Manually override that.
    vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    vb.customize ["modifyvm", :id, "--memory", BOX_MEMORY]
    vb.customize ["modifyvm", :id, "--cpus", 4]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    # enable NAT adapter cable https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=838999
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

  config.vm.define "dokku-daemon", primary: true do |vm|
    vm.vm.synced_folder File.dirname(__FILE__), "/dokku-daemon"
    vm.vm.network :forwarded_port, guest: 3000, host: 3000
    vm.vm.network :forwarded_port, guest: 80, host: 8080
    vm.vm.hostname = "dokku.me"
    vm.vm.network :private_network, ip: "10.0.0.2"
    vm.vm.provision :shell, :inline => "apt-get update > /dev/null && apt-get -qq -y install git > /dev/null"
    vm.vm.provision :shell, :inline => "wget https://raw.githubusercontent.com/dokku/dokku/#{DOKKU_TAG}/bootstrap.sh && DOKKU_TAG=#{DOKKU_TAG} bash bootstrap.sh"
    vm.vm.provision :shell, :inline => "wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz"
    vm.vm.provision :shell, :inline => "sudo tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz"
    vm.vm.provision :shell, :inline => "echo 'export PATH=$PATH:/usr/local/go/bin' > ~/.profile"
  end
end
