contributes_to :notify_new_machine_start

param :current_user
#param 'environment'

accept_extra_params

execute do |params|
  $logger.info "+++ track_new_machine +++ "
  $logger.info "params :"
  $logger.info params.pretty_inspect
  $logger.info "extra params:"
  $logger.info params['extra_params'].pretty_inspect if params['extra_params']
  
  machine_name = "#{params["extra_params"]["vm_name"]}.#{params["extra_params"]["machine"]}"
  $logger.info "machine name : #{machine_name}"
  
  env = params["extra_params"]["environment"] if params['extra_params']
  if not env
    env = params['environment'] if params['environment']
  end
  
  Machine.new(
    :name => machine_name, 
    :state => "installing",
    :owner => params["current_user"],
    :environment => env
  ).save()
end  