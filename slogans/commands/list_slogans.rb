description "returns a list of slogans"

display_type :list

execute do |params|
  @plugin.state[:drop_dir].read_local_dropdir.map { |x| x["slogan"] }
end
