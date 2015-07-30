name 'chef-provisioner'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures chef-provisioner'
long_description 'Installs/Configures chef-provisioner'
version '0.1.0'

#depends 'enterprise'
#depends 'chef_server'


filename = "/root/attributes.rb"
File.open(filename, 'w') do |file|
  File.open(
    "/opt/opscode/embedded/cookbooks/private-chef/attributes/default.rb", 'r'
  ).read.each_line do |line|
    line_mod = line.sub("default", "default['chef-platform']")
    puts line_mod
    line_mod = line.sub('# default', 'default')
    puts line_mod
    file.write "# #{line_mod}"
  end
end

filename = "/root/attributes.rb"
File.open('filename','a') do |mergedfile|
  @files = ['/opt/opscode/embedded/cookbooks/enterprise/attributes/default.rb',
            '/opt/opscode/embedded/cookbooks/private-chef/attributes/default.rb',
            ' /opt/opscode/embedded/cookbooks/chef-ha-drbd/attributes/default.rb']
  for file in @files
    text = File.open(file, 'r').read
    text.each_line do |line|
    	puts line
      mergedfile << line.chomp + "\n"
    end
  end
end
