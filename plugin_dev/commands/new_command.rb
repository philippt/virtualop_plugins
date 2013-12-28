param! 'name', '', :default_param => true
param! 'plugin'

execute do |params|
  plugin_path = @op.plugin_by_name(params['plugin']).path
  
  @op.with_machine('localhost') do |localhost|
    file_name = "#{plugin_path}/commands/#{params['name']}.rb"
    process_local_template(:new_command, localhost, file_name, binding())
  end  
end
