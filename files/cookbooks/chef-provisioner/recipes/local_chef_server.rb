directory '/etc/opscode' do
  mode 0755
  recursive true
end

directory '/etc/opscode-analytics' do
  recursive true
end

directory '/etc/supermarket' do
  recursive true
end

support_provision_package 'chef-server-core' do
  source node['support_provision']['server']['source']['core']
  reconfigure true
  # local_package true
  action :install
end

support_provision_package 'opscode-manage' do
  source "/srv/packages/packages/opscode-manage_1.9.0-1_amd64.deb"
  notifies :reconfigure, 'support_provision_package[opscode-manage]'
end

 directory "/var/opt/chef-provisioner/.chef" do
  owner "root"
  group "root"
  mode "0755"
end

execute "chef-server-ctl user-create provisioner Chef Provisioner root@localhost provsionerpass --filename /var/opt/chef-provisioner/.chef/provisioner.pem" do
  user 'root'
  not_if "chef-server-ctl user-list | grep provisioner"
end

execute "chef-server-ctl org-create provisioner-server 'provisioner-server' --association provisioner --filename /root/.chef//var/opt/chef-provisioner/provisioner.pem" do
  user 'root'
  not_if "chef-server-ctl org-list | grep provisioner-server"
end

template "/var/opt/chef-provisioner/.chef/provisioner-knife.rb" do
  source "knife.rb.erb"
  owner "root"
  group "root"
  mode "0644"
  # variables( :config_var => node[:configs][:config_var] )
end

execute "knife ssl fetch -c /var/opt/chef-provisioner/.chef/provisioner-knife.rb" do
  user 'root'
  cwd '/var/opt/chef-provisioner'
end