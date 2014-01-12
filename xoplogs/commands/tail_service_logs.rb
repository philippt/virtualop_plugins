param :machine
param :service
param "lines", "the number of lines to display", :default_value => 10

on_machine do |machine, params|
  service_logs = machine.find_logs.select { |x| x["service"] == params["service"] }.map { |x| x["path"] }
  
  p = {"file_name" => service_logs}.merge_from params, :lines
  
  if machine.machine_detail['os'] && machine.machine_detail['os'] == 'windows'
    machine.win_tail(p)
  else
    machine.tail(p)
  end
end
