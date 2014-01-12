
execute do |params|
  raise "no installation target configured" unless config_string('installation_target')
  
  # TODO we could use a slightly more complicated algorithm here
  config_string('installation_target').first
end  