require 'mixlib/shellout'
require 'optparse'
require 'fileutils'
require 'erb'
require 'json'


add_command 'add_policyfile', 'Prompts for values to mandatory settings and creates .envrc', 2 do
  msg "Gathering Cluster Information"
  puts "Provide the following information to generate your config."

  msg "Gathering Cluster Information"
  puts "Provide the following information to generate your config."

  cluster_name = ask_for('PolicyFile Cluster', 'cluster_name')
  policy_group = ask_for('PolicyGroup Name', 'group_name')
  policy_name = ask_for('PolicyFile Name', 'policy_name')
  github_url = ask_for('Github Url', 'policy_name')
  branch_or_release = ask_for('Branch Name or Release', 'master')

  # if cluster_name == "enter_name"
  #   puts "No name given, exitting"
  #   exit!(0)
  # else
  policy_path = "/etc/chef-provisioner/policyfiles.d/#{policy_name}.json"
  policy_src = { "name" => "#{cluster_name}_#{policy_group}_#{policy_name}",
                 "policy_name" => policy_name,
                 "policy_group" => policy_group,
                 "cluster_name" => cluster_name,
                 "github_url" => github_url,
                 "revision" => branch_or_release
                 }

  File.open(policy_path, "w") do |file|
    file.write policy_src.to_json
  end

  json_path = "#{base_path}/embedded/cookbooks/add_policyfile.json"
  json_src = { "run_list" => ["recipe[chef-provisioner::add_policyfile]"]}

  File.open(json_path, "w") do |file|
    file.write json_src.to_json
  end

  chef_args = "-l fatal"

  status = run_chef(attributes_path, chef_args)
  exit!(status.success? ? 0 : 1)
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
