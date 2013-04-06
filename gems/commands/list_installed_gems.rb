description 'lists all ruby gems installed on the selected machine'

param :machine

display_type :table
add_column :name
add_column :version

mark_as_read_only

on_machine do |machine, params|
  the_list = ""
  # TODO hardcoded sudo
  the_list = machine.ssh("command" => "gem list").split("\n")
  @op.read_gem_list("lines" => the_list)
end
