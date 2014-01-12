description "returns information about a working copy"

param :machine
param :working_copy

#mark_as_read_only

display_type :hash

with_contributions do |result, params|
  if result.has_key?("type")
    result["types"] = result["type"].split(',')
  end
    
  result
end