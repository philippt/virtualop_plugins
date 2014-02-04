description "returns a list with all database logging tables older than a certain timeframe"

param "age", "number of days after which tables are considered to be old", :default_value => config_string('archive_min_age')

#mark_as_read_only

display_type :list

ONE_DAY = 24 * 60 * 60

execute do |params|
  result = []
    
  max_age_days = params["age"].to_i
  
  @op.with_machine("localhost") do |machine|
    machine.show_tables("database" => config_string("db_name")).each do |table|
      matched = /.+_((\d{4})(\d{2})(\d{2}))$/.match(table["name"])
      if matched
        timestamp = Time.local(matched.captures[1], matched.captures[2], matched.captures[3])
        potential_max_age = Time.at(timestamp.to_i + (ONE_DAY))
        if potential_max_age.to_i < (Time.now().to_i - (max_age_days * ONE_DAY))
          result << table["name"]
        end
      end
    end
  end
    
  result
end
