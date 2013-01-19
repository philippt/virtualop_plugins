description "returns the nagios host objects that are configured on this nagios machine"

param :machine

mark_as_read_only

display_type :list

on_machine do |machine, params|
  machine.list_files("directory" => config_string("config_root")).map do |x|
    /(.+)\.cfg$/.match x
    $1
  end
end
