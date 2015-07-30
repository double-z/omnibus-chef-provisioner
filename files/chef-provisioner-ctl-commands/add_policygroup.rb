require 'mixlib/shellout'
require 'optparse'
require 'fileutils'
require 'erb'
require 'json'


add_command 'add_policygroup', 'Prompts for values to mandatory settings and creates .envrc', 2 do
  msg "Gathering policygroup Information"
  puts "Provide the following information to generate your config."

  msg "Gathering policygroup Information"
  puts "Provide the following information to generate your config."

  policygroup_name = ask_for('policygroup Name', 'enter_name')

  if policygroup_name == "enter_name"
    puts "No name given, exitting"
    exit!(0)
  else
    cluster_name = ask_for('Cluster Name', 'enter_name')
    full_name = "#{cluster_name}_#{policygroup_name}"
    policygroup_path = "/etc/chef-provisioner/policygroups.d/#{full_name}.json"
    policygroup_src = { "name" => full_name,
                        "policygroup_name" => policygroup_name,
                        "cluster_name" => cluster_name
                        }

    File.open(policygroup_path, "w") do |file|
      file.write policygroup_src.to_json
    end
    status = run_command("#{base_path}/bin/chef-apply #{base_path}/embedded/cookbooks/chef-provisioner/recipes/add_policygroup.rb")
    exit!(status.success? ? 0 : 1)
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
