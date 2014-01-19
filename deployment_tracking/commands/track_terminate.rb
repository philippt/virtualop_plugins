# TODO would it be better to contribute to terminate?
contributes_to :notify_cleanup_machine_start

param :current_user

accept_extra_params

execute do |params|
  machine_name = params["extra_params"]["machine"]
  m = Machine.find_by_name(data["name"])
  m.delete()
end