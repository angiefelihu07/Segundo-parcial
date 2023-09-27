Vagrant.configure("2") do |config|
  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  config.vm.define :cliente do |cliente|
    cliente.vm.box = "generic/centos9s"
    cliente.vm.network :private_network, ip: "192.168.50.2"
    cliente.vm.hostname = "cliente"
    cliente.vm.synced_folder ".", "/vagrant"
  end

  config.vm.define :servidor do |servidor|
    servidor.vm.box = "generic/centos9s"
    servidor.vm.network :private_network, ip: "192.168.50.3"
    servidor.vm.network :private_network, ip: "172.16.0.3"
    servidor.vm.network :forwarded_port, host: 5567, guest:80
    servidor.vm.network :forwarded_port, host: 5568, guest:443
    servidor.vm.hostname = "servidor"
    servidor.vm.synced_folder ".", "/vagrant"
  end

  config.vm.define :firewall do |firewall|
    firewall.vm.box = "generic/centos9s"
    firewall.vm.network :private_network, ip: "192.168.50.4"
    firewall.vm.hostname = "firewall"
    firewall.vm.synced_folder ".", "/vagrant"
  end
end