param! "request_id", "the ID of the request that should be cancelled"

execute do |params|
  @op.with_machine(@op.whoareyou("name_only" => true)) do |me|
    me.kill_processes_like("string" => params["request_id"])
  end
end