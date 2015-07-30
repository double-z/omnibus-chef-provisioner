#
# Cookbook Name:: provisioner
# Recipe:: add_policyname
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
# Provisioner::Config.load_policynames!(
#   "#{node['provisioner']['config_directory']}/policynames.d",
#   node,
# )

if node['provisioner']['policynames'] && !node['provisioner']['policynames'].empty?
  node['provisioner']['policynames'].each do |pg|
    directory "#{node['provisioner']['var_directory']}/#{pg['policygroup']}/#{pg['policyname']}" do
      owner node['provisioner']['ctl_user']
      group node['provisioner']['ctl_group']
      mode '0700'
    end

    git "#{node['provisioner']['var_directory']}/policies/#{pg['policygroup']}/#{pg['policyname']}" do
      repository pg['repository_url']
      reference pg['git_ref']
      user node['provisioner']['ctl_user']
      group node['provisioner']['ctl_group']
      action :sync
    end
  end
end
