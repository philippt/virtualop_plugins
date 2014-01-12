param :machine

on_machine do |machine, params|
  detail = @op.machine_detail(params)
  @op.with_machine(detail["host_name"]) do |host|
    host.start_vm("name" => params["machine"].split(".").first)
  end
end
