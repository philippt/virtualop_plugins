description "adds a script that should be included into the forward section"

param :machine, "the machine onto which the iptables script is generated"
param! "source_machine", "name of the machine for which this include has been generated", :lookup_method => lambda { @op.list_machines.map { |x| x["name"] } }
param! "service", "name of the service for which the include has been generated"
param! "content", "the script content"

on_machine do |machine, params|
  machine.write_file("target_filename" => "#{config_string('include_dropdir')}/forward/#{params["source_machine"]}_#{params["service"]}.conf", "content" => params["content"])
end
