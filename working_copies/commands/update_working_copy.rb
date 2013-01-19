description 'pulls new changes into a working copy'

param :machine
param :working_copy
  
on_machine do |machine, params|
  wc = machine.working_copy_details(params)
  
  case wc["type"]
  when "git"
    machine.update_git_working_copy(params)
  when "dropbox"
    machine.sync_dropbox_folder("directory" => wc["path"], "path" => wc["project_path"], "force" => "true")
  end
end