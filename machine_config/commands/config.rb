description "returns machine-specific configuration"

param :machine

display_type :hash

mark_as_read_only

on_machine do |machine, params|
  config_file_name = ".vop/config"
  
  result = {}
  
  if machine.file_exists("file_name" => config_file_name)
    config_file = machine.read_file("file_name" => config_file_name)
    result = @op.instance_eval(config_file)
  end
  
  result
end
