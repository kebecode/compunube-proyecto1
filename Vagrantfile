# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

  config.vm.define :balancer do |balancer|
    balancer.vm.box = "bento/ubuntu-20.04"
    balancer.vm.network :private_network, ip: "192.168.40.2"
    balancer.vm.hostname = "balancer"
    balancer.vm.provision "shell", path: "scriptBalancer.sh", :args => "192.168.40.2"
  end

  config.vm.define :node1 do |node1|
    node1.vm.box = "bento/ubuntu-20.04"
    node1.vm.network :private_network, ip: "192.168.40.3"
    node1.vm.hostname = "node1"
    node1.vm.provision "shell", path: "scriptApp.sh", :args => "192.168.40.3 2 192.168.40.2"
  end

  config.vm.define :node2 do |node2|
    node2.vm.box = "bento/ubuntu-20.04"
    node2.vm.network :private_network, ip: "192.168.40.4"
    node2.vm.hostname = "node2"
    node2.vm.provision "shell", path: "scriptApp.sh", :args => "192.168.40.4 2 192.168.40.2"
  end
end