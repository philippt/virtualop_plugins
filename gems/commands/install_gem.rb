description 'installs the specified ruby gem'

param :machine
param "name", "the name of the gem to install", :mandatory => true
param "version", "the version that should be installed"

on_machine do |machine, params|
    
  exists_already = machine.list_installed_gems.select do |row|
    row["name"] == params["name"] and
    (not params.has_key?("version") or (row["version"] == params["version"]))
  end.size > 0
  
  if exists_already
    @op.comment("message" => "gem #{params["name"]} is already installed.")
  else
    # TODO hardcoded sudo
    command_string = "gem install "
    command_string += "--version #{params["version"]} " if params.has_key?("version")
    command_string += "#{params["name"]}"
    command_string += " --no-rdoc --no-ri"
    machine.ssh_and_check_result("command" => command_string, "user" => "root")
    
    # @op.without_cache do 
      # machine.list_installed_gems
    # end
  end
end