# chef-provisioner

TODO: Enter the cookbook description here.

Requires:
- prov root/home
PROVISIONER_ROOT_DIR
/var/opt/chef-provisioner

- prov conf
PROVISIONER_CONF_DIR
/var/opt/chef-provisioner/etc
ln -s /var/opt/chef-provisioner/etc /etc/chef-provisioner

- prov provisioner-ernvrc
PROVISIONER_ENVRC_FILE
/var/opt/chef-provisioner/etc/provisioner-envrc.sh

- prov .chef
/var/opt/chef-provisioner/.chef

- local-policies
POLICIES_ROOT_DIR
/var/opt/chef-provisioner/policies

- local-policies policygroups
/var/opt/chef-provisioner/policies/prod
/var/opt/chef-provisioner/policies/preprod

---------
CHEF PLATFORM SETUP
chef-provisioner-ctl chef_platform_setup
---------

# Workarounds till zero support - For now use hosted for initial. Could also install chef-server local. 
- prov initial knife
['CHEF_PROVISIONER_KNIFE']
/var/opt/chef-provisioner/.chef/provisioner-knife.rb
['CHEF_PLATFORM_KNIFE']
/var/opt/chef-provisioner/.chef/knife.rb
- chef-platform policygroups

/var/opt/chef-provisioner/chef-platform/prod
/var/opt/chef-provisioner/local-platform/prod

/var/opt/chef-provisioner/chef-platform/preprod
/var/opt/chef-provisioner/local-platform/preprod

---------
LOCAL PLATFORM SETUP 
- local-platform group dir is created when the chef-platform for group/env is created
- command will prompt for git user setup if doesn't exist
- then will prompt for policy provisioner repo name, GH repo and user/org then branch to pull
chef-provisioner-ctl local_platform_setup
---------

