param :machine
param! :environment

on_machine do |machine, params|
  machine.write_environment(params)
  machine.reboot_and_wait
end
