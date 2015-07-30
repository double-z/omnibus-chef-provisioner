require 'mixlib/shellout'
require 'optparse'
require 'pp'

add_command 'chef_platform_provision', 'Runs chef provision command within auspices of env', 2 do

  # provision, bootstrap, install omnibus-provisioner-client reconfigure
  options = {}
  OptionParser.new do |opts|
    opts.on '-g', '--policygroup Name' do |pgroup|
      options[:policygroup] = pgroup
    end
    opts.on '-g', '--policygroup Name' do |pgroup|
      options[:policygroup] = pgroup
    end
    opts.on '-c', '--component [EXTENSION]' do |comp|
      options[:component] = comp
    end
    opts.on '-d', '--destroy [EXTENSION]' do |destr|
      options[:destroy] = true
    end
  end.parse!

  policygroup = options[:policygroup]
  comp = options[:component] || false
  platform_conf = JSON.parse(::IO.read(::File.join(chef_provisioner_dir, "etc", "#{policygroup}_chef_platform.json")))
  # pp "platform_conf: #{platform_conf}"
  components = platform_conf["delivery-cluster"]["components"] || []
  pp components

  # Chef Server Goes first
  # if !breakpoint

  if comp && comp == "chef-server"

    cs_policyfile_path = File.join(chef_platform_policyfiles, "chef-server-12/standalone/Policyfile.rb")
    cs_use_recipe = "chef_server"
    cs_nodename = "chef-server-#{policygroup}"
    do_run_command(cs_policyfile_path, cs_use_recipe, cs_nodename, options)
  end

  # if !breakpoint
  if comp && comp == "delivery"
    # Delivery Server
    ds_policyfile_path = File.join(chef_platform_policyfiles, "delivery_server/Policyfile.rb")
    ds_use_recipe = "delivery_server"
    ds_nodename = "delivery-server-#{policygroup}"
    do_run_command(ds_policyfile_path, ds_use_recipe, ds_nodename, options)
    # end
    # if !breakpoint

    # Delivery Builders
    db_policyfile_path = File.join(chef_platform_policyfiles, "delivery_builders/Policyfile.rb")
    db_use_recipe = "delivery_builders"
    db_nodename = "delivery-builders-#{policygroup}"
    do_run_command(db_policyfile_path, db_use_recipe, db_nodename, options)
  end

  # end
  # if !breakpoint

  if comp && comp == "analytics"
    ab_policyfile_path = File.join(chef_platform_policyfiles, "analytics/bootstrap/Policyfile.rb")
    ab_use_recipe = "analytics_bootstrap"
    ab_nodename = "analytics-server-#{policygroup}"
    do_run_command(ab_policyfile_path, ab_use_recipe, ab_nodename, options)

    cs_policyfile_path = File.join(chef_platform_policyfiles, "chef-server-12/standalone/analytics/Policyfile.rb")
    cs_use_recipe = "chef_server_analytics"
    cs_nodename = "chef-server-#{policygroup}"
    do_run_command(cs_policyfile_path, cs_use_recipe, cs_nodename, options)

    ab_policyfile_path = File.join(chef_platform_policyfiles, "analytics/Policyfile.rb")
    ab_use_recipe = "analytics"
    ab_nodename = "analytics-server-#{policygroup}"
    do_run_command(ab_policyfile_path, ab_use_recipe, ab_nodename, options)
  end

end

def breakpoint
  true
end
