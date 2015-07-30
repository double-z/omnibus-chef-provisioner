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

name "chef-provisioner-ctl"
# To make omnibus git caching happy
default_version "0.0.1"

# dependency "runit"
dependency "omnibus-ctl"

source path: "#{project.files_path}/#{name}-commands"

build do
  block do
    erb source: "chef-provisioner-ctl.erb",
      dest:   "#{install_dir}/bin/chef-provisioner-ctl",
      mode:   0755,
    vars:   {
      embedded_bin: "#{install_dir}/embedded/bin",
      embedded_service: "#{install_dir}/embedded/service",
    }
  end

  block do
    erb source: "omnibus-addon-ctl.erb",
      dest:   "#{install_dir}/embedded/bin/omnibus-addon-ctl",
      mode:   0755,
    vars:   {
      embedded_bin: "#{install_dir}/embedded/bin",
    }
  end

  # additional omnibus-ctl commands
  sync "#{project_dir}", "#{install_dir}/embedded/service/omnibus-ctl/"
end
