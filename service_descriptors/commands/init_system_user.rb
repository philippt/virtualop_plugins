param :machine

param! 'user', 'name for the user account that should be initialized'

notifications

on_machine do |machine, params|
  user_name = params['user']
  
  unless machine.list_system_users.select { |x| x['name'] == user_name }.size > 0
    machine.add_system_user user_name
  end
  # TODO don't do this by default and don't do it more than once
  begin
    machine.grant_sudo_all user_name
  rescue
    # TODO handle
  end
  
  # TODO do we really want to do this just for installing one service?
  machine.chown("file_name" => "/etc/vop/installed_services", "ownership" => "#{user_name}:")
end  
