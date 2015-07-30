require 'mixlib/shellout'
require 'optparse'

add_command 'chef_platform_setup', 'Configure Chef Platform Settings', 2 do

  # provision, bootstrap, install omnibus-provisioner-client reconfigure
  options = {}
  OptionParser.new do |opts|
    opts.on '-g', '--policygroup Name' do |pgroup|
      options[:policygroup] = pgroup
    end
    opts.on '-s', '--show_command [EXTENSION]' do |rec|
      options[:show_command] = true
    end
    opts.on '-d', '--destroy [EXTENSION]' do |destr|
      options[:destroy] = true
    end
  end.parse!

#   command_text = "/opt/chef-provisioner/embedded/bin/rake"
#   command_text += " setup:generate_env"
#   command_text += " -f #{chef_platform_root}/Rakefile"
#   # command_text += " -f #{ENV['CHEF_PLATFORM_ROOT_DIR']}/chef_platform/Rakefile"
#   status = run_command(command_text)
#   exit!(status.success? ? 0 : 1)
# end

   policygroup = options[:policygroup]

    msg 'Gathering Cluster Information'
    puts 'Provide the following information to generate your policygroup.'

    config_opts = {}
    config_opts['components'] = []
    puts "\nGlobal Attributes"

    config_opts['cluster_id']   = ask_for('Cluster ID', policygroup)
    puts "\nAvailable Drivers: [ aws | ssh | vagrant ]"
    config_opts['driver_name']  = ask_for('Driver Name', 'vagrant')

    puts "\nDriver Information [#{config_opts['driver_name']}]"
    config_opts['driver'] = {}
    case config_opts['driver_name']
    when 'ssh'
      config_opts['driver']['ssh_username'] = ask_for('SSH Username', 'vagrant')
      # TODO: Ask for 'password' when we are ready to encrypt it
      loop do
        puts 'Key File Not Found' if config_opts['driver']['key_file']
        config_opts['driver']['key_file']   = ask_for('Key File',
                                                  File.expand_path('~/.vagrant.d/insecure_private_key'))
        break if File.exist?(config_opts['driver']['key_file'])
      end
    when 'aws'
      config_opts['driver']['key_name']           = ask_for('Key Name: ')
      config_opts['driver']['ssh_username']       = ask_for('SSH Username', 'ubuntu')
      config_opts['driver']['image_id']           = ask_for('Image ID', 'ami-3d50120d')
      config_opts['driver']['subnet_id']          = ask_for('Subnet ID', 'subnet-19ac017c')
      config_opts['driver']['security_group_ids'] = ask_for('Security Group ID', 'sg-cbacf8ae')
      config_opts['driver']['use_private_ip_for_ssh'] = ask_for('Use private ip for ssh?', 'yes')
    when 'vagrant'
      config_opts['driver']['ssh_username']           = ask_for('SSH Username', 'vagrant')
      config_opts['driver']['vm_box']                 = ask_for('Box Type: ', 'opscode-centos-6.6')
      config_opts['driver']['image_url']              = ask_for('Box URL: ', 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box')
      config_opts['driver']['use_private_ip_for_ssh'] = ask_for('Use private ip for ssh?', 'yes')
      loop do
        puts 'Key File Not Found' if config_opts['driver']['key_file']
        config_opts['driver']['key_file']   = ask_for('Key File',
                                                  File.expand_path('~/.vagrant.d/insecure_private_key'))
        break if File.exist?(config_opts['driver']['key_file'])
      end
    else
      puts 'ERROR: Unsupported Driver.'
      puts 'Available Drivers are [ vagrant | aws | ssh ]'
      exit 1
    end

    puts "\nChef Server"
    config_opts['chef_server'] = {}
    config_opts['chef_server']['organization'] = ask_for('Organization Name', policygroup)
    config_opts['chef_server']['existing']     = ask_for('Use existing chef-server?', 'no')
    unless config_opts['chef_server']['existing']
      case config_opts['driver_name']
      when 'aws'
        config_opts['chef_server']['flavor'] = ask_for('Flavor', 'c3.xlarge')
      when 'ssh'
        config_opts['chef_server']['host'] = ask_for('Host', '33.33.33.10')
      when 'vagrant'
        config_opts['chef_server']['vm_hostname'] = 'chef.example.com'
        config_opts['chef_server']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.10'}")
        config_opts['chef_server']['vm_memory'] = ask_for('Memory allocation', '2048')
        config_opts['chef_server']['vm_cpus'] = ask_for('Cpus alotted', '2')
       end
    end

    puts "\nDelivery Server"
    config_opts['delivery'] = {}
    config_opts['delivery']['version']      = ask_for('Package Version', 'latest')
    config_opts['delivery']['enterprise']   = ask_for('Enterprise Name', policygroup)
    config_opts['delivery']['artifactory']  = ask_for('Use chef artifactory?', 'no')
    config_opts['delivery']['license_file'] = ask_for('License File',
                                                  File.expand_path('~/delivery.license'))
    unless File.exist?(config_opts['delivery']['license_file'])
      puts 'License File Not Found'
      puts 'Please confirm the location of the license file.'
      exit 1
    end

    case config_opts['driver_name']
    when 'aws'
      config_opts['delivery']['flavor'] = ask_for('Flavor', 'c3.xlarge')
    when 'ssh'
      config_opts['delivery']['host'] = ask_for('Host', '33.33.33.11')
    when 'vagrant'
      config_opts['delivery']['vm_hostname'] = 'delivery.example.com'
      config_opts['delivery']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.11'}")
      config_opts['delivery']['vm_memory'] = ask_for('Memory allocation', '2048')
      config_opts['delivery']['vm_cpus'] = ask_for('Cpus alotted', '2')
    end

    puts "\nAnalytics Server"
    if ask_for('Enable Analytics?', 'no')
      config_opts['components'] << "analytics"
      config_opts['analytics'] = {}
      case config_opts['driver_name']
      when 'aws'
        config_opts['analytics']['flavor'] = ask_for('Flavor', 'c3.xlarge')
      when 'ssh'
        config_opts['analytics']['host'] = ask_for('Host', '33.33.33.12')
      when 'vagrant'
        config_opts['analytics']['vm_hostname'] = 'analytics.example.com'
        config_opts['analytics']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.12'}")
        config_opts['analytics']['vm_memory'] = ask_for('Memory allocation', '2048')
        config_opts['analytics']['vm_cpus'] = ask_for('Cpus alotted', '2')
      end
    end

    puts "\nSupermarket Server"
    if ask_for('Enable Supermarket?', 'no')
      config_opts['components'] << "supermarket"
      config_opts['supermarket'] = {}
      case config_opts['driver_name']
      when 'aws'
        config_opts['supermarket']['flavor'] = ask_for('Flavor', 'c3.xlarge')
      when 'ssh'
        config_opts['supermarket']['host'] = ask_for('Host', '33.33.33.13')
      when 'vagrant'
        config_opts['supermarket']['vm_hostname'] = 'analytics.example.com'
        config_opts['supermarket']['network'] = ask_for('Network Config', ":private_network, {:ip => '33.33.33.12'}")
        config_opts['supermarket']['vm_memory'] = ask_for('Memory allocation', '2048')
        config_opts['supermarket']['vm_cpus'] = ask_for('Cpus alotted', '2')
      end
    end

    puts "\nBuild Nodes"
    config_opts['builders'] = {}
    config_opts['builders']['count'] = ask_for('Number of Build Nodes', '1')
    case config_opts['driver_name']
    when 'aws'
      config_opts['builders']['flavor'] = ask_for('Flavor', 'c3.large')
    when 'ssh'
      1.upto(config_opts['builders']['count'].to_i) do |i|
        h = ask_for("Host for Build Node #{i}", "33.33.33.1#{i + 3}")
        config_opts['builders'][i] = { 'host' => h }
      end
    when 'vagrant'
      1.upto(config_opts['builders']['count'].to_i) do |i|
        net = ask_for("Network for Build Node #{i}", ":private_network, {:ip => '33.33.33.1#{i + 3}'}")
        mem = ask_for("Memory allocation for Build Node #{i}", '2048')
        cpu = ask_for("Cpus alotted for Build Node #{i}", '2')
        config_opts['builders'][i] = { 'network' => net, 'vm_memory' => mem, 'vm_cpus' => cpu }
      end
    end
    if ask_for('Specify a delivery-cli artifact?', 'no')
      config_opts['builders']['delivery-cli'] = {}
      config_opts['builders']['delivery-cli']['artifact'] = ask_for('Delivery-cli Artifact: ')
      config_opts['builders']['delivery-cli']['checksum'] = ask_for('Delivery-cli Checksum: ')
    end

    msg "Rendering Chef Platform COnfig => #{ENV['PROVISIONER_ROOT_DIR']}/etc/#{policygroup}_chef_platform.json"

    render_policygroup(policygroup, config_opts)
end