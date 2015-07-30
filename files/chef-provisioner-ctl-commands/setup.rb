require 'mixlib/shellout'
require 'optparse'
require 'fileutils'
require 'erb'
require 'json'


add_command 'setup', 'Prompts for values to mandatory settings and creates .envrc', 2 do
  msg "Gathering Cluster Information"
  puts "Provide the following information to generate your config."

  options = Hash.new
  puts "\nGlobal Attributes"

  options["default_package"] = ask_for('default_package', 'chef-server-core-12.0.8-1.el6.x86_64.rpm')
  options["manage_package"] = ask_for('manage_package', 'opscode-manage-1.13.0-1.el5.x86_64.rpm')
  options["reporting_package"] = ask_for('reporting_package', 'opscode-reporting-1.3.0-1.el6.x86_64.rpm')
  options['run_pedant?']  = ask_for('Run Pedant?', 'true')
  if options['run_pedant?'] == 'true'
    options['run_pedant'] = true
  else
    options['run_pedant'] = false
  end
  # FIRST FIGURE OUT DRIVER/PROVIDER
  options['provider']  = ask_for('Driver Name', 'vagrant')

  puts "\nDriver Information [#{options['provider']}]"
  case options['provider']
  when 'vagrant'
    options['vagrant_options'] = Hash.new
    options['vagrant_options'].tap do |opts|
      opts['box'] = ask_for('box', 'centos-65')
      opts['box_url'] = ask_for('box_url',
                                "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{options['vagrant_options']['box']}_chef-provisionerless.box")
      opts['disk2_size'] = ask_for('disk2_size', '2')
    end
  end

  # WHATS OUR LAYOUT
  options['layout'] = Hash.new
  options['layout']['topology'] = ask_for('Cluster Layout', 'standalone')
  case options['layout']['topology']
  when 'tier'
    options['layout']['api_fqdn'] = ask_for('api_fqdn', 'api.ubuntu.vagrant')
    options['layout']['manage_fqdn'] = ask_for('manage_fqdn', 'manage.ubuntu.vagrant')
    options['layout']['analytics_fqdn'] = ask_for('analytics_fqdn', 'analytics.ubuntu.vagrant')

    # Setup Backends
    options['layout']['backend_vip'] = {}
    options['layout']['backend_vip'].tap do |opts|
      opts['hostname'] = ask_for('hostname', 'backend.ubuntu.vagrant')
      opts['ipaddress'] = ask_for('ipaddress', '33.33.33.31')
      opts['heartbeat_device'] = ask_for('heartbeat_device', 'eth2')
      opts['device'] = ask_for('device', 'eth1')
    end
    options['layout']['backends'] = {}
    backend_nodes = ask_for('backend_node_count', 2)
    1.upto(backend_nodes.to_i).each do |num|
      options['layout']['backends'].tap do |opts|
        opts["backend#{num}"] = {}
        opts["backend#{num}"]['hostname'] = ask_for('hostname', "backend#{num}.ubuntu.vagrant")
        opts["backend#{num}"]['ipaddress'] = ask_for('ipaddress', "33.33.33.3#{num}")
        opts["backend#{num}"]['cluster_ipaddress'] = ask_for('cluster_ipaddress', "33.33.34.3#{num}")
        opts["backend#{num}"]['memory'] = ask_for('memory', 2560) if (options['provider'] == "vagrant")
        opts["backend#{num}"]['cpu'] = ask_for('cpu', 2) if (options['provider'] == "vagrant")
        opts["backend#{num}"]['bootstrap'] = ask_for('bootstrap', (num == 1) ? true : false)
      end
    end

    # Setup Backends
    options['layout']['backend_vip'] = {}
    options['layout']['backend_vip'].tap do |opts|
      opts['hostname'] = ask_for('hostname', 'backend.ubuntu.vagrant')
      opts['ipaddress'] = ask_for('ipaddress', '33.33.33.21')
      opts['heartbeat_device'] = ask_for('heartbeat_device', 'eth2')
      opts['device'] = ask_for('device', 'eth1')
    end
    options['layout']['frontends'] = {}
    frontend_nodes = ask_for('frontend_node_count', 1)
    1.upto(frontend_nodes).each do |num|
      options['layout']['frontends'].tap do |opts|
        opts["frontend#{num}"] = {}
        opts["frontend#{num}"]['hostname'] = ask_for('hostname', "frontend#{num}.ubuntu.vagrant")
        opts["frontend#{num}"]['ipaddress'] = ask_for('ipaddress', "33.33.33.2#{num}")
        opts["frontend#{num}"]['memory'] = ask_for('memory', 2560) if (options['provider'] == "vagrant")
        opts["frontend#{num}"]['cpu'] = ask_for('cpu', 2) if (options['provider'] == "vagrant")
      end
    end

    File.open(
      "#{ENV['PROVISIONER_ROOT_DIR']}/#{options['layout']['topology']}-#{options['provider']}-config.json","w"
    ) do |config|
      puts "Writing to #{ENV['CLUSTERS_DIRECTORY']}/opscode-platform/#{options['layout']['topology']}-#{options['provider']}-:"
      puts JSON.pretty_generate(options)
      puts
      puts "content out end"
      config.puts JSON.pretty_generate(options)
    end
  when 'standalone'
    options['layout']['topology'] = 'standalone'
    options['layout']['api_fqdn'] = ask_for('api_fqdn', 'api.ubuntu.vagrant')
    options['layout']['manage_fqdn'] = ask_for('manage_fqdn', 'manage.ubuntu.vagrant')
    options['layout']["standalones"] = {}
    options['layout']["standalones"]["standalone"] = {}
    options['layout']["standalones"]["standalone"]['hostname'] = ask_for('hostname', "standalone.ubuntu.vagrant")
    options['layout']["standalones"]["standalone"]['ipaddress'] = ask_for('ipaddress', "33.33.33.23")
    options['layout']["standalones"]["standalone"]['cluster_ipaddress'] = ask_for('cluster_ipaddress', "33.33.33.23")
    options['layout']["standalones"]["standalone"]['memory'] = ask_for('memory', 2560) if (options['provider'] == "vagrant")
    options['layout']["standalones"]["standalone"]['cpu'] = ask_for('cpu', 2) if (options['provider'] == "vagrant")
    options['layout']['virtual_hosts'] = {
      'standalone.ubuntu.vagrant' => options['layout']["standalones"]["standalone"]['ipaddress'],
      options['layout']['api_fqdn'] => options['layout']["standalones"]["standalone"]['ipaddress'],
      options['layout']['manage_fqdn'] => options['layout']["standalones"]["standalone"]['ipaddress']
    }
  end
  puts JSON.pretty_generate(options)
end
