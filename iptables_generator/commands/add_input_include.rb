description "adds a script that should be included into the input section"

param :machine, "the machine onto which the iptables script is generated"
param! "source_machine", "name of the machine for which this include has been generated", :lookup_method => lambda { @op.list_machines.map { |x| x["name"] } }
param! "service", "name of the service for which the include has been generated"
param! "content", "the script content"

on_machine do |machine, params|
  file_name = [ params["source_machine"], params["service"] ].join("_") + '.conf'
  machine.write_file("target_filename" => "#{config_string('include_dropdir')}/input/#{file_name}", "content" => params["content"])
end
