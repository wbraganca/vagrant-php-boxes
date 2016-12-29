class Php52
  def Php52.configure(config, settings, scriptDir)
    config.vm.define :vmphp52 do |vmphp52|
      vmphp52.vm.provision "web", type: "shell", inline: 'bash /vagrant/provision/setup-php-5.2.sh'

      # Create users
       if settings.has_key?("users") and settings["users"].to_a.any?
          settings["users"].each do |u|
            vmphp52.vm.provision "shell", run: 'always' do |s|
              s.name = "Adding user: " + u["fullname"]
              s.path = scriptDir + "/scripts/add-user.sh"
              s.args = [u["username"], u["fullname"], u["email"], u["password"]]
            end
          end
      end

      # Local Machine Hosts
      #
      # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
      # installed, the following will automatically configure your local machine's hosts file to
      # be aware of the domains specified below.
      if defined? VagrantPlugins::HostsUpdater and settings['sites'].to_a.any?
        vmphp52.hostsupdater.aliases = settings['sites'].map { |site| site['map'] }
      end

      # Restart services
      vmphp52.vm.provision :shell, path: scriptDir + "/provision/configure-php-5.2.sh", run: 'always'
      vmphp52.vm.provision :shell, path: scriptDir + "/scripts/restart-services-php-5.2.sh", run: 'always'
    end
  end
end
