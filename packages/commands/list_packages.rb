description "lists packages that are installed on this system"

param :machine

add_columns [ :name, :version ]

with_contributions do |result, params|
  result
end

