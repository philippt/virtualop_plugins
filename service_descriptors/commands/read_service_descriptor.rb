description "reads a service descriptor and returns a hash with the data"

param :machine
param! "file_name", "path to the service descriptor file"

display_type :hash

#mark_as_read_only

on_machine do |machine, params|
  full_name = params["file_name"]
  source = machine.read_file("file_name" => full_name)
      
  $logger.debug "found #{full_name} : ***\n#{source}\n***\n"
  name = full_name.split("/").last.split(".").first
  service = ServiceDescriptorLoader.read(name, source).services.first
  
  service["file_name"] = full_name
  
  install_command_name = "#{name}_install"
  broker = @op.local_broker
  install_command = nil
  begin
    install_command = broker.get_command(install_command_name)
    $logger.info("found install command #{install_command.name}")
    service["install_command_name"] = install_command.name
  rescue Exception => e
    $logger.info("did not find install_command #{install_command_name} : #{e.message}")
    service["install_command_name"] = nil
  end
  
  service
end