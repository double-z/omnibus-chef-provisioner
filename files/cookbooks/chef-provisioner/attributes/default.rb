# # provisioner configuration
#
# Attributes here will be applied to configure the application and the services
# it uses.
#
# Most of the attributes in this file are things you will not need to ever
# touch, but they are here in case you need them.
#
# A `provisioner-ctl reconfigure` should pick up any changes made here.
#
# If /etc/provisioner/provisioner.json exists, its attributes will be loaded
# after these, so if you have that file with the contents:
#

default['provisioner']['fqdn'] = node['fqdn']

default['provisioner']['chef_server_url'] = nil

default['provisioner']['install_directory'] = '/opt/chef-provisioner'
default['provisioner']['var_directory'] = '/var/opt/chef-provisioner'
default['provisioner']['config_directory'] = "#{node['provisioner']['var_directory']}/etc"
default['provisioner']['policies_directory'] = "#{node['provisioner']['var_directory']}/policies"
default['provisioner']['log_directory'] = '/var/log/chef-provisioner'
default['provisioner']['ctl_user'] = 'provisioner'
default['provisioner']['ctl_group'] = 'provisioner'
default['provisioner']['global_knife'] = "#{node['provisioner']['var_directory']}/.chef/knife.rb"
default['provisioner']['provisioner_knife'] = "#{node['provisioner']['var_directory']}/.chef/provisioner-knife.rb"

default['enterprise']['name'] = 'provisioner'

# Enterprise uses install_path internally, but we use install_directory because
# it's more consistent. Alias it here so both work.
default['provisioner']['install_path'] = node['provisioner']['install_directory']

#
# If these are present, metrics can be reported to a StatsD server.
default['provisioner']['statsd_url'] = nil
default['provisioner']['statsd_port'] = nil

default['provisioner']['policygroups'] = []
# default['provisioner']['policygroups'] = [{
#   "name" => "default",
#   "repository" => "https://github.com/double-z/chef_platform",
#   "reference" => "master"
#   }]