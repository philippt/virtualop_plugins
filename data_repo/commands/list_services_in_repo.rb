description "returns a list of all service directories found in a xop data repo"

param :data_repo

mark_as_read_only

display_type :list

execute do |params|
  result = []
  repo_row = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
  @op.read_apache_dir_listing({
    "url" => repo_row["url"]      
  }).each do |dump|
    matcher = /(.+)\/$/.match(dump)
    if matcher then
      result << matcher.captures[0]
    end
  end
  result
end
