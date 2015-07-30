require 'fileutils'
require 'erb'
require 'json'

# Helpers for `chef-provisioner-ctl chef_platform_setup`
class DeliveryConfigAttrs
  def initialize(name, options)
    options.each_pair do |key, value|
    	puts key
      instance_variable_set('@' + key.to_s, value)
    end
    @name = name
    @data = json
  end

  def self.template
    '<%= JSON.pretty_generate(@data) %>'
  end

  def json
    {
      'name' => @name,
      'description' => 'Delivery Cluster Environment',
      'json_class' => 'Chef::Environment',
      'chef_type' => 'environment',
      'override_attributes' => {
        'delivery-cluster' => {
          'id' => @cluster_id,
          'components' => @components,
          'driver' => @driver_name,
          @driver_name => @driver,
          'chef-server' => @chef_server,
          'delivery' => @delivery,
          'analytics' => (@analytics if @analytics && ! @analytics.empty?),
          'supermarket' => (@supermarket if @supermarket && ! @supermarket.empty?),
          'builders' => @builders
        }.delete_if { |_k, v| v.nil? }
      }
    }
  end

  def do_binding
    binding
  end
end

def bool(string)
  case string
  when 'no'
    false
  when 'yes'
    true
  else
    string
  end
end

def ask_for(thing, default = nil)
  thing = "#{thing} [#{default}]: " if default
  stdin = nil
  loop do
    print thing
    stdin = STDIN.gets.strip
    case default
    when 'no', 'yes'
      break if stdin.empty? || stdin.eql?('no') || stdin.eql?('yes')
      print "Answer (yes/no) "
    when nil
      break unless stdin.empty?
    else
      break
    end
  end
  bool(stdin.empty? ? default : stdin)
end

def msg(string)
  puts "\n#{string}\n"
end

def render_policygroup(policygroup, options)
  ::FileUtils.mkdir_p "#{ENV['PROVISIONER_ROOT_DIR']}/etc"

  env_file = File.open("/tmp/#{policygroup}.json", 'w+')
  env_file << ERB.new(DeliveryConfigAttrs.template)
    .result(DeliveryConfigAttrs.new(policygroup, options).do_binding)
  env_file.close

  full_env = JSON.parse(File.read("/tmp/#{policygroup}.json"))
  attrs = {}
  attrs['delivery-cluster'] = full_env['override_attributes']['delivery-cluster']
  ::File.open("#{ENV['PROVISIONER_ROOT_DIR']}/etc/#{policygroup}_chef_platform.json", 'wb') do |file|
    file.write JSON.pretty_generate(attrs)
  end
end

# Helper Command for `chef-provisioner-ctl chef_platform_provision`
def do_run_command(policyfile_path, use_recipe, nodename, options)
  command_text = "#{chef_bin} provision #{options[:policygroup]}"
  command_text += " --sync #{policyfile_path}"
  command_text += " --cookbook #{platform_cookbook}"
  command_text += " -c #{knife_rb}"
  command_text += " -n #{nodename}"
  command_text += " --destroy" if options[:destroy]
  command_text += " --recipe #{use_recipe}"
  if options[:show_command]
    puts
    puts "Command For #{nodename}"
    puts
    puts command_text
    puts
  else
    run_command(command_text)
  end
end

# Variable Helpers
def chef_provisioner_dir
  ENV['PROVISIONER_ROOT_DIR']
end

def chef_platform_dir
  ENV['CHEF_PLATFORM_DIR']
end

def chef_platform_policyfiles
  ::File.join(chef_platform_dir, "policies")
end

def platform_cookbook
  ::File.join(chef_platform_dir, "chef-platform-provision")
end

def chef_bin
  "/opt/chef-provisioner/bin/chef"
end

def knife_rb
  ENV['CHEF_PLATFORM_KNIFE']
end

def io_for_live_stream
  if STDOUT.tty?
    STDOUT
  else
    nil
  end
end

# def chef_platform_json_attributes
#   ::File.join(policyfile_root, "chef-platform-attributes.json")
# end

# def running_json
#   ::JSON.parse(File.read(chef_platform_json_attributes))
# end

# def policyfile_root
#   ::File.join(chef_provisioner_root_dir, "policyfiles")
# end

# def chef_platform_config
#   ::JSON.parse(IO.read(::File.join(ENV['CHEF_PROVISIONER_CONF_DIR'], "chef-platform-#{options[:policygroup].json}")))
# end

# def run_provision_command(command)
# 	puts "ENV"
# 	puts "ENV"
# 	puts "ENV"
# 	puts ENV["PROVISIONER_ROOT_DIR"]
# 	puts "ENV"
# 	puts "ENV"
# 	puts "ENV"
#   system({ "PROVISIONER_ROOT_DIR" => ENV["PROVISIONER_ROOT_DIR"] }, command)
#   $?
# end

# def run_base_command(nodename, options)
#   policygroup = options[:policygroup]
#   knife_rb = ENV['CHEF_PLATFORM_KNIFE']
#   policyfile_root = ::File.join(ENV['PROVISIONER_ROOT_DIR'], "policies", policygroup, "monitor")
#   policyfile_path = ::File.join(policyfile_root, "Policyfile.rb")
#   policyfile_cookbook = ::File.join(policyfile_root, "provision")
#   chef_bin = "/opt/chef-provisioner/bin/chef"

#   command_text = "#{chef_bin} provision #{policygroup}"
#   command_text += " --policy-name base"
#   command_text += " -c #{knife_rb}"
#   command_text += " -n #{nodename}"
#   status = run_command(command_text)
#   exit!(status.success? ? 0 : 1)
# end

# def run_monitor_command(nodename, options)
#   policygroup = options[:policygroup]
#   knife_rb = ENV['CHEF_PLATFORM_KNIFE']
#   policyfile_root = ::File.join(ENV['PROVISIONER_ROOT_DIR'], "policies", policygroup, "monitor")
#   policyfile_path = ::File.join(policyfile_root, "Policyfile.rb")
#   chef_bin = "/opt/chef-provisioner/bin/chef"

#   command_text = "#{chef_bin} provision #{policygroup}"
#   command_text += " --policy-name monitor"
#   command_text += " -c #{knife_rb}"
#   command_text += " -n #{nodename}"
#   command_text += " --debug"
#   status = run_command(command_text)
#   exit!(status.success? ? 0 : 1)
# end