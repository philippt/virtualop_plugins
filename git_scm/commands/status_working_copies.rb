description "returns a list of all working copies showing if there are local changes"

mark_as_read_only

param :machine

add_columns [ :name, :change_count ]

on_machine do |machine, params|
  result = []
  machine.list_working_copies("type" => "git").each do |working_copy|
    changes = machine.list_changes_in_working_copy("working_copy" => working_copy["name"])
    result << {
      "name" => working_copy["name"],
      "change_count" => changes.size
    }
  end
  result
end  
