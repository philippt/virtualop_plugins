description "returns detail information about dropbox projects"

param :machine
param :working_copy

#mark_as_read_only

display_type :hash

contributes_to :working_copy_details

on_machine do |machine, params|
  wc = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first
  path = wc["path"]
  
  if wc["type"] == "dropbox"
    sync_record_dir = "/var/log/virtualop/dropbox_sync/"
    sync_record = sync_record_dir[0..-2] + wc["path"]
    record = YAML.load(machine.read_file("file_name" => sync_record))
    wc["project_path"] = record["path"]
    wc["project"] = record["path"]["/projects/".length..record["path"].length-1]
    wc["sync_record"] = record["files"]    
  end
 
  wc
end
