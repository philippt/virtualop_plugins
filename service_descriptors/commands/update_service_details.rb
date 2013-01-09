description "writes information into the service descriptor located on the machine where the service is installed"

param :machine
param :service

accept_extra_params

on_machine do |machine, params|
  file_name = config_string('service_config_dir') + '/' + params["service"]
  result = {}
  if machine.file_exists("file_name" => file_name)
    content = machine.read_file("file_name" => file_name)
    result = YAML.load(content)
  end
  
  puts "old service details:"
  pp result
  
  if params.has_key?("extra_params")
    params["extra_params"].each do |k,v|
      result[k] = v
    end
    #result.merge! params["extra_params"]
  end
  
  puts "updated service details:"
  pp result
  
  machine.hash_to_file(
    "file_name" => file_name, 
    "content" => result
  )
end  
