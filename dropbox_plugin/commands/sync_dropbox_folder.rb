description "synchronizes a dropbox folder onto a machine, keeping a local store on the machine of file metadata for syncing"

param :dropbox_token
param! "path", "the dropbox folder that should be synced"

param :machine
param! "directory", "path on the machine into which the dropbox folder should be written"

param "force", "if set to true, will re-read the dropbox folder metadata without using the cache", :lookup_method => lambda { %w|true false| }

on_machine do |machine, params|
  sync_record_file = "/var/log/virtualop/dropbox_sync" + params["directory"]
  sync_record = {}
  if machine.file_exists("file_name" => sync_record_file)
    record = YAML.load(machine.read_file("file_name" => sync_record_file))
    sync_record = record["files"]
  end
  
  pp sync_record
  
  machine.mkdir("dir_name" => params["directory"])

  local_files = machine.find("path" => params["directory"])
  
  reload_block = lambda do
    @op.troll_dropbox_folders("path" => params["path"])
  end
  remote_files = if params.has_key?("force") && params["force"] == "true"
    @op.without_cache do
      reload_block.call()  
    end
  else
    reload_block.call()
  end
   
  synced_files = sync_record.clone
  
  sync_file = lambda do |full_path, file|
    machine.mkdir("dir_name" => File.dirname(full_path))
    unless file["is_dir"]
      machine.write_file("target_filename" => full_path, "content" => @op.dropbox_read_file("path" => file["path"]))
    end
    
    machine.allow_access_for_apache("file_name" => File.dirname(full_path))
    synced_files[full_path] = file["rev"]
  end
    
  remote_files.each do |file|
    relative_path = file["path"][params["path"].length + 1..file["path"].length-1]
    full_path = params["directory"] + '/' + relative_path
    
    puts "syncing #{full_path} (#{relative_path})..."
    if local_files.include? full_path
      puts "  local file detected"
      if (sync_record.has_key?(full_path)) and (sync_record[full_path] == file["rev"])
        puts "  already up to date (rev #{sync_record[full_path]}), no need to sync."
      else 
        puts "  overwriting with new rev >>#{file["rev"]}<< (old rev >>#{sync_record[full_path]}<<)"
        sync_file.call(full_path, file)
      end
    else
      sync_file.call(full_path, file)
    end
  end
  
  # TODO delete local files that don't exist remote anymore
  
  machine.mkdir("dir_name" => File.dirname(sync_record_file))
  # TODO maybe store the dropbox username as well?
  record = {
    "path" => params["path"],
    "files" => synced_files
  }
  machine.write_file("target_filename" => sync_record_file, "content" => record.to_yaml())
end
