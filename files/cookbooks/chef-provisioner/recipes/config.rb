#
# Cookbook Name:: provisioner
# Recipe:: config
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

Provisioner::Config.load_or_create!(
  "#{node['provisioner']['config_directory']}/provisioner.rb",
  node,
)

Provisioner::Config.load_running_from_json!(
  "#{node['provisioner']['config_directory']}/provisioner-running.json",
  node,
)

provisioner_user = node['provisioner']['ctl_user']
provisioner_group = node['provisioner']['ctl_group']

directory node['provisioner']['log_directory'] do
  owner provisioner_user
  group provisioner_group
  mode '0755'
end

# directory node['provisioner']['var_directory'] do
#   owner provisioner_user
#   group provisioner_group
#   mode '0755'
# end

directory node['provisioner']['config_directory'] do
  owner provisioner_user
  group provisioner_group
end

directory "#{node['provisioner']['var_directory']}/policies" do
  owner provisioner_user
  group provisioner_group
end