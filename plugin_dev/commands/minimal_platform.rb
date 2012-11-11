description "installs a minimal set of infrastructure for running a platform on a virtualization host"

param :machine
param! "domain", "the domain root for the web applications"

on_machine do |host, params|
  host.setup_vm(
    "vm_name" => "nagios",
    "memory_size" => 1024,
    "canned_service" => "nagios/nagios",
    "extra_params" => {
      "domain" => "nagios.#{params["domain"]}"
    }
  )
  
  host.setup_vm(
    "vm_name" => "xoplogs",
    "memory_size" => 1024,
    "disk_size" => 100,
    "github_project" => "philippt/xoplogs",
    "extra_params" => {
      "domain" => "xoplogs.#{params["domain"]}"
    }
  )
  
  host.setup_vm(
    "vm_name" => "xoplogs",
    "memory_size" => 1024,
    "disk_size" => 100,
    "github_project" => "philippt/xoplogs",
    "extra_params" => {
      "domain" => "xoplogs.#{params["domain"]}"
    }
  )

  
  @op.configure_nagios_config_generator("nagios_machine_name" => "nagios.#{host.name}", "default_services" => ["ssh"])
  @op.configure_xoplogs("xoplogs_machine" => "xoplogs.#{host.name}")
  
end
