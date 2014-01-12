execute do |params|
  @op.configure_stacks unless @op.list_plugins.include? "stacks"
  @op.load_plugin("machine" => "localhost", "plugin_file_name" => "#{@op.home("machine" => "localhost")}/virtualop_plugins/plugin_dev/plugin_dev.plugin")
end