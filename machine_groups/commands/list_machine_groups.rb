description "returns a list of machine groups (might be recursive)"

add_columns [ :path, :name, :parent ]

param "path", "filter to use on the path attribute", :default_param => true

mark_as_read_only

with_contributions do |result, params|
  result << {
    "name" => "root",
    "path" => "/"
  }
  
  if params.has_key?("path")
    result = result.select do |row|
      /^#{params["path"]}/ =~ row["path"] 
    end
  end
  
  result
end


