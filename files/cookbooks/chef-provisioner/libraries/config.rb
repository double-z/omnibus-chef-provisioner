require 'fileutils'
require 'securerandom'

# Manages configuration
class Provisioner
  module Config
    def self.load_or_create!(filename, node)
      create_directory!(filename)
      if File.exist?(filename)
        node.from_file(filename)
      else
        # Write out the new file, but with everything commented out
        File.open(filename, 'w') do |file|
          File.open(
            "#{node['provisioner']['install_directory']}/embedded/cookbooks/chef-provisioner/attributes/default.rb", 'r'
          ).read.each_line do |line|
            file.write "# #{line}"
          end
        end
        Chef::Log.info("Creating configuration file #{filename}")
      end
    rescue Errno::ENOENT => e
      Chef::Log.warn "Could not create #{filename}: #{e}"
    end

    def self.load_clusters!(dirname, node)
      c = []
      files = []
      files = Array(Dir.glob(::File.join(dirname, "*.json"))).sort
      if !files.empty?
        files.each do |f|
          h = Chef::JSONCompat.from_json(open(f).read)
          c << h
        end
        node.override['provisioner']['clusters'] = Array(c)
      end
    rescue => e
      Chef::Log.warn "Could not read attributes from #{dirname}: #{e}"
    end

    def self.load_policygroups!(dirname, node)
      c = []
      files = []
      files = Array(Dir.glob(::File.join(dirname, "*.json"))).sort
      if !files.empty?
        files.each do |f|
          h = Chef::JSONCompat.from_json(open(f).read)
          c << h
        end

        node.override['provisioner']['policygroups'] = c
      end
    rescue => e
      Chef::Log.warn "Could not read attributes from #{dirname}: #{e}"
    end

    def self.load_policynames!(dirname, node)
      c = []
      files = []
      files = Array(Dir.glob(::File.join(dirname, "*.json"))).sort
      if !files.empty?
        files.each do |f|
          h = Chef::JSONCompat.from_json(open(f).read)
          c << h
        end

        node.override['provisioner']['policynames'] = c
      end
    rescue => e
      Chef::Log.warn "Could not read attributes from #{dirname}: #{e}"
    end

    # Read in a JSON file for attributes and consume them
    def self.load_running_from_json!(filename, node)
      create_directory!(filename)
      if File.exist?(filename)
        data = Chef::JSONCompat.from_json(open(filename).read)
        node.consume_attributes(
          'provisioner' => data['provisioner']
        )
      end
    rescue => e
      Chef::Log.warn "Could not read attributes from #{filename}: #{e}"
    end

    # Read in the filename (as JSON) and add its attributes to the node object.
    # If it doesn't exist, create it with generated secrets.
    def self.load_or_create_secrets!(filename, node)
      create_directory!(filename)
      secrets = Chef::JSONCompat.from_json(File.open(filename).read)
    rescue Errno::ENOENT
      begin
        secrets = { 'secret_key_base' => SecureRandom.hex(50) }

        open(filename, 'w') do |file|
          file.puts Chef::JSONCompat.to_json_pretty(secrets)
        end
        Chef::Log.info("Creating secrets file #{filename}")
      rescue Errno::EACCES, Errno::ENOENT => e
        Chef::Log.warn "Could not create #{filename}: #{e}"
      end

      node.consume_attributes('provisioner' => secrets)
    end

    # Take some node attributes and return them on each line as:
    #
    # export ATTR_NAME="attr_value"
    #
    # If the value is a String or Number and the attribute name is attr_name.
    # Used to write out environment variables to a file.
    def self.environment_variables_from(attributes)
      attributes.reduce "" do |str, attr|
        puts attr[0]
        if attr[1].is_a?(String) || attr[1].is_a?(Numeric) || attr[1] == true || attr[1] == false || !attr[0].to_s == "user"
          str << "export #{attr[0].upcase}=\"#{attr[1]}\"\n" 
        else
          str << ''
        end
      end
    end

    def self.create_directory!(filename)
      dir = File.dirname(filename)
      FileUtils.mkdir(dir, :mode => 0700) unless Dir.exist?(dir)
    rescue Errno::EACCES => e
      Chef::Log.warn "Could not create #{dir}: #{e}"
    end
    private_class_method :create_directory!
  end
end
