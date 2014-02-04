description "returns the names of all commands that should be executed by the crawler on a machine"

param :machine

execute do |params|
  result = []
  @op.plugins.each do |plugin|
    result += plugin.state[:commands_for_crawling] if plugin.state.has_key? :commands_for_crawling
  end
  result
end

