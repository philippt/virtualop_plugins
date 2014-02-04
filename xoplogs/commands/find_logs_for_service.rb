param :machine
param :service

add_columns [ :service, :path, :source, :format, :parser ]

on_machine do |machine, params|
  machine.find_logs.select { |x| x["service"] == params["service"] }
end
