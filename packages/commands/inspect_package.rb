param :machine
param! "name", "the package to inspect", :default_param => true

display_type :list

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when 'centos', 'sles'
    machine.ssh("rpm -ql #{params['name']}").split("\n")
  else
    raise "inspect_package does not support distribution #{distribution} yet - please complain somewhere."
  end 
end
