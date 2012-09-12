def include_for_crawling
  #puts @plugin.name
  @plugin.state[:commands_for_crawling] ||= []
  @plugin.state[:commands_for_crawling] << @command.name
end