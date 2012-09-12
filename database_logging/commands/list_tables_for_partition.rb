description "creates the tables for a new partition"

param! "partition_name", "the identifier for the partition (will be part of the table name)"

display_type :list

execute do |params|
  
  dbh = @plugin.state[:dbh]
  res = dbh.query("SHOW TABLES LIKE '%_#{params["partition_name"]}'")
  result = []
  res.each do |row|
    result << row[0]
  end
  result
end  