#
# Cookbook Name:: provisioner
# Recipe:: add_policygroup
#
# Copyright 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'json'
if !node['provisioner']
  require_relative "../libraries/config.rb"

  raise "Run Reconfigure First" unless ::File.exists?("/etc/chef-provisioner/provisioner-running.json")

  Provisioner::Config.load_running_from_json!(
    "/etc/chef-provisioner/provisioner-running.json",
    node,
  )
end


# Provisioner::Config.load_policygroups!(
#   "/etc/chef-provisioner/policygroups.d",
#   node,
# )

node['provisioner'].tap do |options|
  if options['policygroups'] && !options['policygroups'].empty?
    options['policygroups'].each do |pg|
      directory "#{options['var_directory']}/policies/#{pg}" do
        owner options['ctl_user']
        group options['ctl_group']
        mode '0755'
      end
    end
  end
end

# Write out a provisioner-running.json at the end of the run
file "#{node['provisioner']['config_directory']}/provisioner-running.json" do
  content Chef::JSONCompat.to_json_pretty('provisioner' => node['provisioner'])
  owner node['provisioner']['ctl_user']
  group node['provisioner']['ctl_group']
  mode '0600'
end

file "#{node['provisioner']['config_directory']}/env" do
  content Provisioner::Config.environment_variables_from(node['provisioner'])
  owner node['provisioner']['ctl_user']
  group node['provisioner']['ctl_group']
  mode '0644'
end
