require 'mixlib/shellout'
require 'optparse'
require 'json'
require 'pp'

add_command 'provision', 'Runs chef provision command within auspices of env', 2 do
  options = {}
  OptionParser.new do |opts|
    opts.on '-c', '--cluster Name' do |cname|
      options[:cluster] = cname
    end
    opts.on '-g', '--policygroup Name' do |pgroup|
      options[:policygroup] = pgroup
    end
    opts.on '-f', '--policyfile Name' do |pfile|
      options[:policyfile] = pfile
    end
    opts.on '-r', '--recipe Recipe' do |rec|
      options[:recipe] = rec
    end
    opts.on '-n', '--number Number' do |num|
      options[:number] = num.to_i
    end
    opts.on '-d', '--destroy Number' do |destr|
      options[:destroy] = destr.to_i
    end
    opts.on '-i', '--increment Number' do |incr|
      options[:increment] = incr.to_i
    end
    opts.on '-s', '--status [EXTENSION]' do |st|
      options[:status] = true
    end
    opts.on '-c', '--converge [EXTENSION]' do |conv|
      options[:converge] = true
    end
    opts.on '-b', '--base [EXTENSION]' do |conv|
      options[:base] = true
    end
    opts.on '-m', '--monitor [EXTENSION]' do |conv|
      options[:monitor] = true
    end
  end.parse!

  counter             = options[:number]
  policyfile          = options[:policyfile]
  policygroup         = options[:policygroup]
  chef_bin            = "/opt/chef-provisioner/bin/chef"
  knife_rb            = ENV['CHEF_PLATFORM_KNIFE']
  policyfile_root     = ::File.join(ENV['PROVISIONER_ROOT_DIR'], "policies", policygroup, policyfile)
  policyfile_path     = ::File.join(policyfile_root, "Policyfile.rb")
  policyfile_cookbook = ::File.join(policyfile_root, "provision")
  state_file          = ::File.join(ENV['PROVISIONER_ROOT_DIR'], "etc", "#{policygroup}-#{policyfile}-running.json")
  running_json        = ::JSON.parse(File.read(state_file))
  running_nodes       = running_json['nodes']
  updated_nodes       = Array.new
  running_nodes.each { |c| updated_nodes << c }

  if options[:status]
    p "-----------"
    p "POLICY_PATH: #{policyfile_root}"
    p "-----------"
    p "* POLICY_GROUP: #{policygroup}"
    p "* POLICY_NAME: #{policyfile}"
    p "- Count: #{running_nodes.count}"
    p "- Nodes:"
    running_nodes.each { |rn| p "-- #{rn}" }
    exit
  end

  if options[:number]
    b = running_nodes.count
    c = options[:number]
    if b == c
    elsif b > c
      counter = b - c
      options_number_direction = "delete"
    elsif b < c
      counter = c - b
      options_number_direction = "increment"
    end
  elsif options[:increment] || options[:destroy]
    counter = options[:increment] || options[:destroy]
  elsif options[:converge]
    counter = running_nodes.count
  end

  1.upto(counter) do |cntr|
    num = false
    if options[:destroy]
      next if running_nodes.count == 0
      num = running_nodes.count - (cntr - 1)
    elsif options[:increment]
      num = running_nodes.count + cntr
    elsif options[:number]
      if options_number_direction == "delete"
        num = running_nodes.count - (cntr - 1)
      elsif options_number_direction == "increment"
        num = running_nodes.count + cntr
      end
    elsif options[:converge]
      num = cntr
    end

    nodename = "#{policyfile.gsub('_', '-')}#{num}"

    # if options[:base]
    #   run_base_command(nodename, options)
    # end

    command_text = "#{chef_bin} provision #{policygroup}"
    command_text += " --sync #{policyfile_path}"
    command_text += " --cookbook #{policyfile_cookbook}"
    command_text += " -c #{knife_rb}"
    command_text += " -n #{nodename}"
    command_text += " --destroy" if options[:destroy] || (options[:number] && options_number_direction == "delete")
    command_text += " --recipe #{options[:recipe]}" if options[:recipe]
    p
    p command_text
    p

    # run_provision_command(command_text)

    # status = r
    run_command(command_text)
    # exit!(status.success? ? 0 : 1)

    # if options[:monitor]
    #   run_monitor_command(nodename, options)
    # end

    if options[:destroy] || (options[:number] && options_number_direction == "delete")
      updated_nodes.delete(nodename)
    elsif options[:increment] ||
        (options[:number] && options_number_direction == "increment") ||
        options[:converge]
      updated_nodes << nodename unless updated_nodes.include?(nodename)
    end

  end

  write_nodes = {}
  write_nodes['nodes'] = updated_nodes
  ::File.open(state_file, 'wb') do |file|
    file.write(JSON.pretty_generate(write_nodes))
  end

end

# def run_provision_command(command)
#   system(command)
#   $?
# end

# # def run_base_command(nodename, options)
# #   policygroup = options[:policygroup]
# #   knife_rb = ENV['CHEF_PLATFORM_KNIFE']
# #   policyfile_root = ::File.join(ENV['PROVISIONER_ROOT_DIR'], "policies", policygroup, "monitor")
# #   policyfile_path = ::File.join(policyfile_root, "Policyfile.rb")
# #   policyfile_cookbook = ::File.join(policyfile_root, "provision")
# #   chef_bin = "/opt/chef-provisioner/bin/chef"

# #   command_text = "#{chef_bin} provision #{policygroup}"
# #   command_text += " --policy-name base"
# #   command_text += " -c #{knife_rb}"
# #   command_text += " -n #{nodename}"
# #   status = run_command(command_text)
# #   exit!(status.success? ? 0 : 1)
# # end

# # def run_monitor_command(nodename, options)
# #   policygroup = options[:policygroup]
# #   knife_rb = ENV['CHEF_PLATFORM_KNIFE']
# #   policyfile_root = ::File.join(ENV['PROVISIONER_ROOT_DIR'], "policies", policygroup, "monitor")
# #   policyfile_path = ::File.join(policyfile_root, "Policyfile.rb")
# #   chef_bin = "/opt/chef-provisioner/bin/chef"

# #   command_text = "#{chef_bin} provision #{policygroup}"
# #   command_text += " --policy-name monitor"
# #   command_text += " -c #{knife_rb}"
# #   command_text += " -n #{nodename}"
# #   command_text += " --debug"
# #   status = run_command(command_text)
# #   exit!(status.success? ? 0 : 1)
# # end

# def is_error?
# end

# def io_for_live_stream
#   if STDOUT.tty?
#     STDOUT
#   else
#     nil
#   end
# end
