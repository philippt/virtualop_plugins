description "returns a list of dropbox projects that have been synchronized onto this machine"

param :machine

mark_as_read_only

contributes_to :list_working_copies
result_as :list_working_copies

on_machine do |machine, params|
  sync_record_dir = "/var/log/virtualop/dropbox_sync/"
  if machine.file_exists("file_name" => sync_record_dir)
    machine.find("type" => "f", "path" => sync_record_dir).map do |path|
      path.strip!
      {
        "path" => path[sync_record_dir.length-1..path.length-1],
        "name" => path.split("/").last,
        "type" => "dropbox"      
      }
    end
  else
    []
  end
end

