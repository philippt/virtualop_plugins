description "returns a list of machine groups (might be recursive)"

add_columns [ :path, :name, :parent ]

mark_as_read_only

with_contributions do |result, params|
  result << {
    "name" => "root",
    "path" => "/"
  }
end


