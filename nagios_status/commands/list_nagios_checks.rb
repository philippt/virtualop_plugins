description "returns service status information for a machine"

param :machine

add_columns [ :name, :status, :last_check ]

include_for_crawling

on_machine do |machine, params|
  result = []
  
  # TODO copied from nagios_config_generator.nagios_file_name
  machine_name = machine.name == "localhost" ? machine.hostname : machine.name
  
  with_nagios do |site|
    site.host_status(machine_name).each do |k,v|
      v["name"] = k
      result << v
    end
  end
  result
end
