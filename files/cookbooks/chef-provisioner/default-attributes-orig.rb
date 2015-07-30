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
#     { "redis": { "enable": false } }
#
# for example, it will set the node['provisioner']['redis'] attribute to false.

# ## Common Use Cases
#
# These are examples of things you may want to do, depending on how you set up
# the application to run.
#
# ### Chef Identity
#
# You will have to set this up in order to log into provisioner and upload
# cookbooks with your Chef server keys.
#
# See the "Chef OAuth2 Settings" section below
#
# ### Using an external Postgres database
#
# Disable the provided Postgres instance and connect to your own:
#
# default['provisioner']['postgresql']['enable'] = false
# default['provisioner']['database']['user'] = 'my_db_user_name'
# default['provisioner']['database']['name'] = 'my_db_name''
# default['provisioner']['database']['host'] = 'my.db.server.address'
# default['provisioner']['database']['port'] = 5432
#
# ### Using an external Redis server
#
# Disable the provided Redis server and use on reachable on your network:
#
# default['provisioner']['redis']['enable'] = false
# default['provisioner']['redis_url'] = 'redis://my.redis.host:6379/0/mydbname
#
# ### Bring your on SSL certificate
#
# If a key and certificate are not provided, a self-signed certificate will be
# generated. To use your own, provide the paths to them and ensure SSL is
# enabled in Nginx:
#
# default['provisioner']['nginx']['force_ssl'] = true
# default['provisioner']['ssl']['certificate'] = '/path/to/my.crt'
# default['provisioner']['ssl']['certificate_key'] = '/path/to/my.key'

# ## Top-level attributes
#
# These are used by the other items below. More app-specific top-level
# attributes are further down in this file.

# The fully qualified domain name. Will use the node's fqdn if nothing is
# specified.
default['provisioner']['fqdn'] = node['fqdn']

# The URL for the Chef server. Used with the "Chef OAuth2 Settings" and
# "Chef URL Settings" below. If this is not set, authentication and some of the
# links in the application will not work.
default['provisioner']['chef_server_url'] = nil
default['provisioner']['clusters'] = []

default['provisioner']['config_directory'] = '/etc/chef-provisioner'
default['provisioner']['install_directory'] = '/opt/chef-provisioner'
default['provisioner']['var_directory'] = '/var/opt/chef-provisioner'

default['provisioner']['app_directory'] = "#{node['provisioner']['var_directory']}/app"
default['provisioner']['clusters_directory'] = "#{node['provisioner']['var_directory']}/clusters"
default['provisioner']['log_directory'] = '/var/log/chef-provisioner'
default['provisioner']['user'] = 'provisioner'
default['provisioner']['group'] = 'provisioner'

# ## Enterprise
#
# The "enterprise" cookbook provides recipes and resources we can use for this
# app.

default['enterprise']['name'] = 'provisioner'

# Enterprise uses install_path internally, but we use install_directory because
# it's more consistent. Alias it here so both work.
default['provisioner']['install_path'] = node['provisioner']['install_directory']

# An identifier used in /etc/inittab (default is 'SV'). Needs to be a unique
# (for the file) sequence of 1-4 characters.
default['provisioner']['sysvinit_id'] = 'SUP'

# ## Nginx

# These attributes control provisioner-specific portions of the Nginx
# configuration and the virtual host for the provisioner Rails app.
default['provisioner']['nginx']['enable'] = false
default['provisioner']['nginx']['force_ssl'] = false
default['provisioner']['nginx']['non_ssl_port'] = 80
default['provisioner']['nginx']['ssl_port'] = 443
default['provisioner']['nginx']['directory'] = "#{node['provisioner']['var_directory']}/nginx/etc"
default['provisioner']['nginx']['log_directory'] = "#{node['provisioner']['log_directory']}/nginx"
default['provisioner']['nginx']['log_rotation']['file_maxbytes'] = 104857600
default['provisioner']['nginx']['log_rotation']['num_to_keep'] = 10

# Redirect to the FQDN
default['provisioner']['nginx']['redirect_to_canonical'] = false

# Controls nginx caching, used to cache some endpoints
default['provisioner']['nginx']['cache']['enable'] = false
default['provisioner']['nginx']['cache']['directory'] = "#{node['provisioner']['var_directory']}/nginx//cache"

# These attributes control the main nginx.conf, including the events and http
# contexts.
#
# These will be copied to the top-level nginx namespace and used in a
# template from the community nginx cookbook
# (https://github.com/miketheman/nginx/blob/master/templates/default/nginx.conf.erb)
default['provisioner']['nginx']['user'] = node['provisioner']['user']
default['provisioner']['nginx']['group'] = node['provisioner']['group']
default['provisioner']['nginx']['dir'] = node['provisioner']['nginx']['directory']
default['provisioner']['nginx']['log_dir'] = node['provisioner']['nginx']['log_directory']
default['provisioner']['nginx']['pid'] = "#{node['provisioner']['nginx']['directory']}/nginx.pid"
default['provisioner']['nginx']['daemon_disable'] = true
default['provisioner']['nginx']['gzip'] = 'on'
default['provisioner']['nginx']['gzip_static'] = 'off'
default['provisioner']['nginx']['gzip_http_version'] = '1.0'
default['provisioner']['nginx']['gzip_comp_level'] = '2'
default['provisioner']['nginx']['gzip_proxied'] = 'any'
default['provisioner']['nginx']['gzip_vary'] = 'off'
default['provisioner']['nginx']['gzip_buffers'] = nil
default['provisioner']['nginx']['gzip_types'] = %w[
  text/plain
  text/css
  application/x-javascript
  text/xml
  application/xml
  application/rss+xml
  application/atom+xml
  text/javascript
  application/javascript
  application/json
]
default['provisioner']['nginx']['gzip_min_length'] = 1000
default['provisioner']['nginx']['gzip_disable'] = 'MSIE [1-6]\.'
default['provisioner']['nginx']['keepalive'] = 'on'
default['provisioner']['nginx']['keepalive_timeout'] = 65
default['provisioner']['nginx']['worker_processes'] = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['provisioner']['nginx']['worker_connections'] = 1024
default['provisioner']['nginx']['worker_rlimit_nofile'] = nil
default['provisioner']['nginx']['multi_accept'] = false
default['provisioner']['nginx']['event'] = nil
default['provisioner']['nginx']['server_tokens'] = nil
default['provisioner']['nginx']['server_names_hash_bucket_size'] = 64
default['provisioner']['nginx']['sendfile'] = 'on'
default['provisioner']['nginx']['access_log_options'] = nil
default['provisioner']['nginx']['error_log_options'] = nil
default['provisioner']['nginx']['disable_access_log'] = false
default['provisioner']['nginx']['default_site_enabled'] = false
default['provisioner']['nginx']['types_hash_max_size'] = 2048
default['provisioner']['nginx']['types_hash_bucket_size'] = 64
default['provisioner']['nginx']['proxy_read_timeout'] = nil
default['provisioner']['nginx']['client_body_buffer_size'] = nil
default['provisioner']['nginx']['client_max_body_size'] = '250m'
default['provisioner']['nginx']['default']['modules'] = []

# ## Rails
#
# The Rails app for provisioner
default['provisioner']['rails']['enable'] = false
default['provisioner']['rails']['port'] = 13000
default['provisioner']['rails']['log_directory'] = "#{node['provisioner']['log_directory']}/rails"
default['provisioner']['rails']['log_rotation']['file_maxbytes'] = 104857600
default['provisioner']['rails']['log_rotation']['num_to_keep'] = 10

# ## Runit

# This is missing from the enterprise cookbook
# see (https://github.com/opscode-cookbooks/enterprise-chef-common/pull/17)
#
# Will be copied to the root node.runit namespace.
default['provisioner']['runit']['svlogd_bin'] = "#{node['provisioner']['install_directory']}/embedded/bin/svlogd"

# ## Sidekiq
#
# Used for background jobs

default['provisioner']['sidekiq']['enable'] = false
default['provisioner']['sidekiq']['concurrency'] = 25
default['provisioner']['sidekiq']['log_directory'] = "#{node['provisioner']['log_directory']}/sidekiq"
default['provisioner']['sidekiq']['log_rotation']['file_maxbytes'] = 104857600
default['provisioner']['sidekiq']['log_rotation']['num_to_keep'] = 10
default['provisioner']['sidekiq']['timeout'] = 30

# ## Unicorn
#
# Settings for main Rails app Unicorn application server. These attributes are
# used with the template from the community Unicorn cookbook:
# https://github.com/opscode-cookbooks/unicorn/blob/master/templates/default/unicorn.rb.erb
#
# Full explanation of all options can be found at
# http://unicorn.bogomips.org/Unicorn/Configurator.html

default['provisioner']['unicorn']['name'] = 'provisioner'
default['provisioner']['unicorn']['copy_on_write'] = true
default['provisioner']['unicorn']['enable_stats'] = false
default['provisioner']['unicorn']['forked_user'] = node['provisioner']['user']
default['provisioner']['unicorn']['forked_group'] = node['provisioner']['group']
default['provisioner']['unicorn']['listen'] = ["127.0.0.1:#{node['provisioner']['rails']['port']}"]
default['provisioner']['unicorn']['pid'] = "#{node['provisioner']['var_directory']}/app/unicorn.pid"
default['provisioner']['unicorn']['preload_app'] = true
default['provisioner']['unicorn']['worker_timeout'] = 15
default['provisioner']['unicorn']['worker_processes'] = node['nginx']['worker_processes']

# These are not used, but you can set them if needed
default['provisioner']['unicorn']['before_exec'] = nil
default['provisioner']['unicorn']['stderr_path'] = nil
default['provisioner']['unicorn']['stdout_path'] = nil
default['provisioner']['unicorn']['unicorn_command_line'] = nil
default['provisioner']['unicorn']['working_directory'] = nil

# These are defined a recipe to be specific things we need that you
# could change here, but probably should not.
default['provisioner']['unicorn']['before_fork'] = nil
default['provisioner']['unicorn']['after_fork'] = nil

# ## App-specific top-level attributes
# #
# # These are used by Rails and Sidekiq. Most will be exported directly to
# # environment variables to be used by the app.
# #
# # Items that are set to nil here and also set in the development environment
# # configuration (https://github.com/opscode/provisioner/blob/master/.env) will
# # use the value from the development environment. Set them to something other
# # than nil to change them.

# default['provisioner']['fieri_url'] = nil
# default['provisioner']['fieri_key'] = nil
# default['provisioner']['from_email'] = nil
# default['provisioner']['github_access_token'] = nil
# default['provisioner']['github_key'] = nil
# default['provisioner']['github_secret'] = nil
# default['provisioner']['google_analytics_id'] = nil
# default['provisioner']['host'] = node['provisioner']['fqdn']
# default['provisioner']['newrelic_agent_enabled'] = 'false'
# default['provisioner']['newrelic_app_name'] = nil
# default['provisioner']['newrelic_license_key'] = nil
# default['provisioner']['port'] = node['provisioner']['nginx']['force_ssl'] ? node['provisioner']['nginx']['ssl_port'] : node['provisioner']['non_ssl_port']
# default['provisioner']['protocol'] = node['provisioner']['nginx']['force_ssl'] ? 'https' : 'http'
# default['provisioner']['pubsubhubbub_callback_url'] = nil
# default['provisioner']['pubsubhubbub_secret'] = nil
# default['provisioner']['redis_url'] = "redis://#{node['provisioner']['redis']['bind']}:#{node['provisioner']['redis']['port']}/0/provisioner"
# default['provisioner']['sentry_url'] = nil

# ### Chef URL Settings
#
# URLs for various links used within provisioner
# default['provisioner']['chef_identity_url'] = "#{node['provisioner']['chef_server_url']}/id"
# default['provisioner']['chef_manage_url'] = node['provisioner']['chef_server_url']
# default['provisioner']['chef_profile_url'] = node['provisioner']['chef_server_url']
# default['provisioner']['chef_sign_up_url'] = "#{node['provisioner']['chef_server_url']}/signup?ref=community"

# URLs for Chef Software, Inc. sites. Most of these have defaults set in
# provisioner already, but you can customize them here to your liking
# default['provisioner']['chef_domain'] = 'getchef.com'
# default['provisioner']['chef_blog_url'] = "https://www.#{node['provisioner']['chef_domain']}/blog"
# default['provisioner']['chef_docs_url'] = "https://docs.#{node['provisioner']['chef_domain']}"
# default['provisioner']['chef_downloads_url'] = "https://downloads.#{node['provisioner']['chef_domain']}"
# default['provisioner']['chef_www_url'] = "https://www.#{node['provisioner']['chef_domain']}"
# default['provisioner']['learn_chef_url'] = "https://learn.#{node['provisioner']['chef_domain']}"

# ### Chef OAuth2 Settings
#
# These settings configure the service to talk to a Chef identity service.
#
# An Application must be created on the Chef server's identity service to do
# this. With the following in /etc/opscode/chef-server.rb:
#
#     oc_id['applications'] = { 'my_provisioner' => { 'redirect_uri' => 'https://my.provisioner.server.fqdn/auth/chef_oauth2/callback' } }
#
# Run `chef-server-ctl reconfigure`, then these values should available in
# /etc/opscode/oc-id-applications/my_provisioner.json.
#
# The chef_oauth2_url should be the root URL of your Chef server.
#
# If you are using a self-signed certificate on your Chef server without a
# properly configured certificate authority, chef_oauth2_verify_ssl must be
# false.
# default['provisioner']['chef_oauth2_app_id'] = nil
# default['provisioner']['chef_oauth2_secret'] = nil
# default['provisioner']['chef_oauth2_url'] = nil
# default['provisioner']['chef_oauth2_verify_ssl'] = true

# ### CLA Settings
#
# These are used for the Contributor License Agreement features. You only need
# them if the cla and/or join_ccla features are enabled (see "Features" below.)
# default['provisioner']['ccla_version'] = nil
# default['provisioner']['cla_signature_notification_email'] = nil
# default['provisioner']['cla_report_email'] = nil
# default['provisioner']['curry_cla_location'] = nil
# default['provisioner']['curry_success_label'] = nil
# default['provisioner']['icla_location'] = nil
# default['provisioner']['icla_version'] = nil
# default['provisioner']['seed_cla_data'] = nil

# ### Features
#
# These control the feature flags that turn features on and off.
#
# Available features are:
#
# * announcement: Display the provisioner initial launch announcement banner
#   (this will most likely be of no use to you, but could be made a
#   configurable thing in the future.)
# * cla: Enable the Contributor License Agreement features
# * fieri: Use the fieri service to report on cookbook quality (requires
#   fieri_url and fieri_key to be set.)
# * github: Enable GitHub integration, used with CLA signing
# * gravatar: Enable Gravatar integration, used for user avatars
# * join_ccla: Enable joining of Corporate CLAs
# * tools: Enable the tools section
# default['provisioner']['features'] = 'tools, gravatar'

# ### robots.txt Settings
#
# These control the "Allow" and "Disallow" paths in /robots.txt. See
# http://www.robotstxt.org/robotstxt.html for more information. Only a single
# line for each item is supported. If a value is nil, the line will not be
# present in the file.
# default['provisioner']['robots_allow'] = '/'
# default['provisioner']['robots_disallow'] = nil

# ### S3 Settings
#
# If these are not set, uploaded cookbooks will be stored on the local
# filesystem (this means that running multiple application servers will require
# some kind of shared storage, which is not provided.)
#
# If these are set, cookbooks will be uploaded to the to the given S3 bucket
# using the provided credentials. A cdn_url can be used for an alias if the
# given S3 bucket is behind a CDN like CloudFront.
default['provisioner']['s3_access_key_id'] = nil
default['provisioner']['s3_bucket'] = nil
default['provisioner']['s3_secret_access_key'] = nil
default['provisioner']['cdn_url'] = nil

# ### SMTP Settings
#
# If none of these are set, the :sendmail delivery method will be used. Using
# the sendmail delivery method requires that a working mail transfer agent
# (usually set up with a relay host) be configured on this machine.
#
# SMTP will use the 'plain' authentication method.
# default['provisioner']['smtp_address'] = nil
# default['provisioner']['smtp_password'] = nil
# default['provisioner']['smtp_port'] = nil
# default['provisioner']['smtp_user_name'] = nil

# ### StatsD Settings
#
# If these are present, metrics can be reported to a StatsD server.
default['provisioner']['statsd_url'] = nil
default['provisioner']['statsd_port'] = nil
