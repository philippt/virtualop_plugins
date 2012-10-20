description "generates a list of categorized plugins in JSON format"

params_as :list_all_plugins

execute do |params|
  @op.list_all_plugins(params).sort_by { |x| x["name"] }.to_json()
end
