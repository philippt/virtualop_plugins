description "returns a list of slogans"

add_columns [ :slogan ]

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir
end
