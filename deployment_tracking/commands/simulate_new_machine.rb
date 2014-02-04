param 'name', '', :default_value => 'foo'
param 'user', '', :default_value => 'philippt'

execute do |params|
  p = {
    'extra_params' => {
      'vm_name' => params['name'],
      'machine' => 'some_host',
      'environment' => 'development',
      'owner' => params['user']
    }
  }
  @op.track_new_machine(p)
end
