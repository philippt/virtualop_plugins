description "adds a service check configuration to nagios"

param :machine
param! "template_name", "the template to evaluate"

on_machine do |machine, params|
  @op.with_machine(config_string('nagios_machine_name')) do |nagios|
    generated = read_local_template(params["template_name"].to_sym, binding())
    
    old_content = nagios.read_file("file_name" => machine.nagios_file_name)
    nagios.append_to_file("file_name" => machine.nagios_file_name, "content" => generated)  
  end
end
