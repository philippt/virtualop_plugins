description "returns all vop logging partitions found in the database"

display_type :list

execute do |params|
  result = []
    
  @op.with_machine("localhost") do |machine|
    machine.show_tables("database" => config_string("db_name")).each do |table|
      matched = /.+_((\d{4})(\d{2})(\d{2}))$/.match(table["name"])
      if matched
        result << matched.captures[0]
      end
    end
  end
  
  result.uniq
end
