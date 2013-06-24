description 'returns a list of accounts at hosting providers'

add_columns [ :type, :alias ]

mark_as_read_only

#contributes_to :list_machine_groups

with_contributions do |result, params|
  
  result.sort_by do |item|
    [ item["contributed_by"], item["alias"] ]
  end
end
