param :machine
param :service
param "lines", "the number of lines to display", :default_value => 10

on_machine do |machine, params|
  service_logs = machine.find_logs.select { |x| x["service"] == params["service"] }.map { |x| x["path"] }
  machine.tail({"file_name" => service_logs}.merge_from params, :lines)
end
