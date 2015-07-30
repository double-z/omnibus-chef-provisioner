#
# Copyright 2014 Chef Software, Inc.
#
# All Rights Reserved.
#

name "chef-provisioner-cookbooks"

# dependency "berkshelf2"
dependency 'rsync'

# source path: "#{project.files_path}/cookbooks/#{project.name}"

source path: "#{project.files_path}/cookbooks/#{project.name}/cookbooks/"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  mkdir "#{install_dir}/embedded/cookbooks"
  command "#{install_dir}/embedded/bin/rsync --delete -a ./ #{install_dir}/embedded/cookbooks/", env: env

  # command "#{install_dir}/embedded/bin/berks vendor #{install_dir}/embedded/cookbooks" \
  #         " -c #{install_dir}/embedded/cookbooks/berks-config.json", env: env
  block do
    File.open("#{install_dir}/embedded/cookbooks/dna.json", "w") do |f|
      f.write JSON.fast_generate(
        run_list: [
          'recipe[chef-provisioner::default]',
        ]
      )
    end
    File.open("#{install_dir}/embedded/cookbooks/show-config.json", "w") do |f|
      f.write JSON.fast_generate(
        run_list: [
          'recipe[chef-provisioner::show_config]',
        ]
      )
    end
    File.open("#{install_dir}/embedded/cookbooks/solo.rb", "w") do |f|
        f.write <<-EOH.gsub(/^ {8}/, '')
        cookbook_path   "#{install_dir}/embedded/cookbooks"
        file_cache_path "#{install_dir}/embedded/cookbooks/cache"
        verbose_logging true
      EOH
    end
  end
end
