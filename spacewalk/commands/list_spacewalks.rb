description "lists all configured spacewalk servers"

mark_as_read_only

#add_columns [ :name ]
display_type :hash

execute do |params|
  #return [] unless config_string('urls', [])
  config_string('urls', {})
end
