description "adds an extra command to nagios"

param "nagios_machine", "a nagios machine to work with", :lookup_method => lambda { @op.list_machines.map { |x| x["name"] }}, :default_value => config_string('nagios_machine_name') 
param! "file_name", "relative file name"
param! "content", "the actual content that should be written into a nagios configuration file"

execute do |params|
  @op.with_machine(params["nagios_machine"]) do |nagios|
    # TODO nagios.mkdir("directory" => config_string("config_root") + '/extra_commands')
    existing = nagios.list_extra_commands()
    next if existing.include? params["file_name"]
  
    nagios.write_file(
      "target_filename" => config_string("config_root") + '/extra_commands/' + params["file_name"], 
      "content" => params["content"],
      "ownership" => "nagios:"
    )
    
    @op.without_cache do
      nagios.list_extra_commands()
    end
  end
end