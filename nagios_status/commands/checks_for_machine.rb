description "returns service status information for a machine"

param :machine

add_columns [ :name, :status, :last_check ]

on_machine do |machine, params|
  result = []
  with_nagios do |site|
    site.host_status(machine.name).each do |k,v|
      v["name"] = k
      result << v
    end
  end
  result
end
