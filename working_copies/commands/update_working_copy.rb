description 'pulls new changes into a working copy'

param :machine
param :working_copy
  
on_machine do |machine, params|
  types = machine.working_copy_details(params)["types"]
  
  # TODO circular dependency kind of thing
  if types.include? "git"
    machine.update_git_working_copy(params)
  elsif types.include? "dropbox"
    machine.sync_dropbox_folder("directory" => wc["path"], "path" => wc["project_path"], "force" => "true")
  end
end