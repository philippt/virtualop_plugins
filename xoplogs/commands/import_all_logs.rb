#result_as :import_logs_for_group

add_columns [ :machine, :status ]

execute do |params|
  result = []
  config_string('auto_import_machine_groups').each do |machine_group|    
    result += @op.import_logs_for_group("machine_group" => machine_group)
  end 
  result
end