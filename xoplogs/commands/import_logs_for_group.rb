description "imports logfiles from all machines in the selected machine group"

param :machine_group

add_columns [ :machine, :status ]

execute do |params|
  result = []
  @op.machines_in_group(params).each do |machine|
    result << { "machine" => machine["name"], "status" => "unknown" }    
    begin
      @op.import_logs("machine" => machine["name"])
      result.last["status"] = "ok"
    rescue => detail
      result.last["status"] = "error"
      result.last["error_message"] = detail.message
    end
  end
  result
end
