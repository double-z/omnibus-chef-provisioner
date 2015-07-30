my_password = 'my_awesome_password'
salt = OpenSSL::Random.random_bytes(32)
iterations = 25000 # Any value above 20k should be fine.

shadow_hash = OpenSSL::PKCS5::pbkdf2_hmac(
  my_password,
  salt,
  iterations,
  128,
  OpenSSL::Digest::SHA512.new
).unpack('H*').first
salt_value = salt.unpack('H*').first

user node['provisioner']['ctl_user'] do
  home node['provisioner']['var_directory']
  manage_home true
  password my_password
  salt salt_value
  iterations 25000
end

group node['provisioner']['ctl_group'] do
  members [node['provisioner']['ctl_user']]
end
