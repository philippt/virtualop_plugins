add_columns [ :name, :type ]

with_contributions do |result, params|
  result << { 'name' => 'xop_apache', 'type' => 'access_log' }
  
  result
end