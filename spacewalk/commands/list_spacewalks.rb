description "lists all configured spacewalk servers"

mark_as_read_only

add_columns [ :name ]

execute do |params|
  return [] unless config_string('urls')
  config_string('urls').map do |url|
    {
      "name" => url
    }
  end
end
