param! "request_id", "the ID of the request that should be cancelled"

execute do |params|
  @op.with_machine(@op.whoareyou("name_only" => true)) do |me|
    morituri = []
    me.processes_like("string" => params["request_id"]).each do |process|
      morituri << process["pid"] unless /interrupt_request/ =~ process["command_short"]
    end
    me.kill_processes("pid" => morituri)
  end
end