description "returns machine-specific configuration"

param :machine

display_type :hash

on_machine do |machine, params|
  config_file_name = ".vop/config"
  if machine.file_exists("file_name" => config_file_name)
    config_file = machine.read_file("file_name" => config_file_name)
    @op.instance_eval(config_file)
  end
end
