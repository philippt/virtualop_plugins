description "lists all unix services (i.e. scripts in /etc/init.d)"

param :machine

mark_as_read_only

display_type :list

on_machine do |machine, params|
  machine.list_files('directory' => '/etc/init.d').select { |name| name != 'README' }
end