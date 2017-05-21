VAGRANTFILE_API_VERSION = "2"
cluster = {
  "dev-1" => { :ip => "10.245.4.2", :cpus => 2, :memory => 4096 },
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = true
    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = false
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
  end

  config.vm.box              = "debian/jessie64"
  #config.vm.box              = "ubuntu/trusty64"
  #config.vm.box              = "opensuse/openSUSE-42.1-x86_64"
  config.vm.box_check_update = false

  # ssh
  config.ssh.username         = 'vagrant'
  config.ssh.insert_key       = false
  config.ssh.forward_agent    = true
  config.ssh.private_key_path = ["#{ENV['HOME']}/.ssh/id_rsa", "#{ENV['HOME']}/.vagrant.d/insecure_private_key"]

  ## synced folders
  config.vm.synced_folder ".", "/vagrant", disabled: true

  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|

      # virtualbox
      cfg.vm.provider :virtualbox do |vb|
        vb.name   = "#{hostname}"
        vb.cpus   = info[:cpus]
        vb.memory = info[:memory]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      # network
      cfg.vm.network :private_network, ip: "#{info[:ip]}", nictype: "virtio"
      cfg.vm.network :forwarded_port, guest: 8201, host: 8241
      cfg.vm.network :forwarded_port, guest: 5436, host: 5446

      cfg.vm.provision "file", source: "#{ENV['HOME']}/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"

      cfg.vm.provision "ansible" do |ansible|
        ansible.limit          = "all"
        ansible.playbook       = "dev.yml"
        ansible.inventory_path = "dev"
      end

      cfg.vm.provision "ansible" do |ansible|
        ansible.limit          = "all"
        ansible.playbook       = "setup.yml"
        ansible.inventory_path = "dev"
        ansible.sudo = true
      end

    end
  end
end
