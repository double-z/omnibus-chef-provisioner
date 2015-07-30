#
# Cookbook Name:: provisioner
# Recipe:: default
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

# Dont need, use root
# include_recipe 'chef-provisioner::user' # Dont need, use root

##
# Create our directories
include_recipe 'chef-provisioner::config'

##
# TODO move these to chef-apply cookbook?
include_recipe 'chef-provisioner::add_policygroups'
include_recipe 'chef-provisioner::add_policynames'

##
# Workaround till zero supports policyfiles. can use hosted too. will flip auto
# to built cluster once cluster is built ala delivery-cluster
include_recipe 'chef-provisioner::local_chef_server'
include_recipe 'chef-provisioner::provisioner_knife_rb'

##
# Write out a provisioner-running.json at the end of the run
file "#{node['provisioner']['config_directory']}/provisioner-running.json" do
  content Chef::JSONCompat.to_json_pretty('provisioner' => node['provisioner'])
  owner node['provisioner']['ctl_user']
  group node['provisioner']['ctl_group']
  mode '0600'
end

##
#write out env vars
directory "/etc/profile.d"

template "/etc/profile.d/provisioner_env.sh" do
	source "provisioner_env.sh.erb"
  # owner node['provisioner']['ctl_user']
  # group node['provisioner']['ctl_group']
  mode '0755'
end
