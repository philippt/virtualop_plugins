description "transfers the config for a data repo to another virtualop"

param :data_repo
param! :machine, "the virtualop instance where the data repo should be added"
param "target_alias", "alias name to use on the target machine (defaults to the original name of the repo)"

on_machine do |machine, params|
  repo = @op.list_data_repos.select { |x| x["alias"] == params["data_repo"] }.first
  target_alias = params.has_key?("target_alias") ? params["target_alias"] : repo["alias"]
  machine.vop_call("command" => "add_data_repo alias=#{target_alias} machine=#{repo["machine"]} url=#{repo["url"]}", "logging" => "true")
end
