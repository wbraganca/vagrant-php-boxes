require 'yaml'
require 'fileutils'

VAGRANTFILE_API_VERSION = "2"

# Box
fileBox = File.expand_path('config/box.yaml', File.dirname(__FILE__))
fileDefaultBox = File.expand_path('config/box.default.yaml', File.dirname(__FILE__))

# copy default settings if local settings not exists
FileUtils.cp fileDefaultBox, fileBox unless File.exist?(fileBox)

# read settings
box = YAML.load_file fileBox

require File.expand_path(File.dirname(__FILE__) + '/provision/' +  box['vm'] +'.rb')

# Settings
fileSettings = File.expand_path('config/settings-' + box['vm'] +'.yaml', File.dirname(__FILE__))
settings = YAML.load_file fileSettings

if (settings.has_key?("keys") and settings['keys'].to_a.any?)
  settings["keys"].each do |key|
    keyPath = File.expand_path(key)
    if (!File.file?(keyPath))
      puts "Error: ssh key not found in path \"#{keyPath}\". Use the \"ssh-keygen\" command to create a pair of keys."
      exit
    end
  end
end

# Version
Vagrant.require_version '>= 1.9.3'

# Configuration
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Set The VM Provider
  ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

  # Configure Local Variable To Access Scripts From Remote Location
  scriptDir = File.dirname(__FILE__)

  config.vm.box_version = settings["box_version"]
  config.vm.box_check_update = settings["box_check_update"]

  # Prevent TTY Errors
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Allow SSH Agent Forward from The Box
  config.ssh.forward_agent = true

  # Configure The Box
  config.vm.box = settings["box"] ||= "ubuntu/xenial64"
  config.vm.hostname = settings["machine_hostname"] ||= env['vm']

  VAGRANT_USER = (if config.vm.box == "ubuntu/xenial64" then "ubuntu" else "vagrant" end)

  # Configure A Private Network IP
  config.vm.network :private_network, ip: settings["machine_ip"] ||= "192.168.10.10"

  # Configure Additional Networks
  if settings.has_key?("networks")
    settings["networks"].each do |network|
      config.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil
    end
  end

  # Configure A Few VirtualBox Settings
  config.vm.provider "virtualbox" do |vb|
    vb.name = settings["machine_name"] ||= "ubuntu16php"
    vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "1024"]
    vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
  end

  # Configure A Few VMware Settings
  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v|
      v.vmx["displayName"] = settings["name"] ||= "ubuntu16php"
      v.vmx["memsize"] = settings["memory"] ||= 1024
      v.vmx["numvcpus"] = settings["cpus"] ||= 1
      v.vmx["guestOS"] = "ubuntu-64"
    end
  end

  # Configure A Few Parallels Settings
  config.vm.provider "parallels" do |v|
    v.update_guest_tools = true
    v.memory = settings["memory"] ||= 1024
    v.cpus = settings["cpus"] ||= 1
  end

  # Standardize Ports Naming Schema
  if (settings.has_key?("ports") and settings['ports'].to_a.any?)
    settings["ports"].each do |port|
      port["guest"] ||= port["to"]
      port["host"] ||= port["send"]
      port["protocol"] ||= "tcp"
    end
  else
    settings["ports"] = []
  end

  # Default Port Forwarding
  default_ports = {
    80   => 8000,
    443  => 44300,
    3306 => 33060,
    5432 => 54320
  }

  # Use Default Port Forwarding Unless Overridden
  unless settings.has_key?("default_ports") && settings["default_ports"] == false
    default_ports.each do |guest, host|
      unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
        config.vm.network "forwarded_port", guest: guest, host: host, host_ip: "localhost", auto_correct: true
      end
    end
  end

  # Add Custom Ports From Configuration
  if settings.has_key?("ports")
    settings["ports"].each do |port|
      config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: true
    end
  end

  # Configure The Public Key For SSH Access
  if settings.include? 'authorize'
    if File.exists? File.expand_path(settings["authorize"])
      config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/#{VAGRANT_USER}/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/#{VAGRANT_USER}/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end
    end
  end

  # Copy The SSH Private Keys To The Box
  if settings.include? 'keys'
    settings["keys"].each do |key|
      config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/#{VAGRANT_USER}/.ssh/$2 && chmod 600 /home/#{VAGRANT_USER}/.ssh/$2"
        s.args = [File.read(File.expand_path(key)), key.split('/').last]
      end
    end
  end

  # Register All Of The Configured Shared Folders
  config.vm.synced_folder ".", '/vagrant'
  if settings.include? 'folders'
    settings["folders"].each do |folder|
      mount_opts = []

      if (folder["type"] == "nfs")
          mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1']
      elsif (folder["type"] == "smb")
          mount_opts = folder["mount_options"] ? folder["mount_options"] : ['vers=3.02', 'mfsymlinks']
      end

      # For b/w compatibility keep separate 'mount_opts', but merge with options
      options = (folder["options"] || {}).merge({ mount_options: mount_opts })

      # Double-splat (**) operator only works with symbol keys, so convert
      options.keys.each{|k| options[k.to_sym] = options.delete(k) }

      config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options

      # Bindfs support to fix shared folder (NFS) permission issue on Mac
      if Vagrant.has_plugin?("vagrant-bindfs")
        config.bindfs.bind_folder folder["to"], folder["to"]
      end
    end
  end

  # Provisioning
  if (box['vm'] == 'php71')
    Php71.configure(config, settings, scriptDir)
  elsif (box['vm'] == 'php70')
    Php70.configure(config, settings, scriptDir)
  elsif (box['vm'] == 'php56')
    Php56.configure(config, settings, scriptDir)
  elsif (box['vm'] == 'php53')
    Php53.configure(config, settings, scriptDir)
  elsif (box['vm'] == 'php52')
    Php52.configure(config, settings, scriptDir)
  else
    puts "Error: vm invalid"
  end
end
