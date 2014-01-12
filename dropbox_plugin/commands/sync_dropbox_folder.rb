description "synchronizes a dropbox folder onto a machine, keeping a local store on the machine of file metadata for syncing"

param :dropbox_token
param! "path", "the dropbox folder that should be synced"

param :machine
param! "directory", "path on the machine into which the dropbox folder should be written"

param "force", "if set to true, will re-read the dropbox folder metadata without using the cache", :lookup_method => lambda { %w|true false| }

param "remote_files", "a list of remote file metadata that should be used for syncing (hack for processing the input of the dropbox APIs delta() method)", :allows_multiple_values => true


on_machine do |machine, params|
  # TODO this should be /var/lib, methinks
  sync_record_file = "/var/log/virtualop/dropbox_sync" + params["directory"]
  sync_record = {}
  if machine.file_exists("file_name" => sync_record_file)
    record = YAML.load(machine.read_file("file_name" => sync_record_file))
    sync_record = record["files"]
  end
  
  #pp sync_record
  
  machine.mkdir("dir_name" => params["directory"])

  local_files = machine.find("path" => params["directory"])
  
  blacklist = %w|.git tmp|
  
  remote_files = nil
  if params.has_key?("remote_files")
    remote_files = params["remote_files"]
  else
    reload_block = lambda do
      @op.troll_dropbox_folders("path" => params["path"], "blacklist" => blacklist)
    end
    
    remote_files = if params.has_key?("force") && params["force"] == "true"
      @op.without_cache do
        reload_block.call()  
      end
    else
      reload_block.call()
    end
    remote_files.map! do |x|
      [ x["path"], x ]
    end
    # TODO use local_files to find out which files need to be deleted, add to remote_files with nil metadata objects 
  end
  
  blacklist.each do |black|
    remote_files.delete_if { |x| x.first.include? "/#{black}/" }
  end
   
  for_the_record = {}
  
  write_record = lambda do |record|
    machine.mkdir("dir_name" => File.dirname(sync_record_file))
    
    sync_record.merge! record
    
    # TODO maybe store the dropbox username as well?
    record = {
      "path" => params["path"],
      "files" => sync_record
    }
    machine.write_file("target_filename" => sync_record_file, "content" => record.to_yaml())
    
    record = {}  
  end
  
  sync_file = lambda do |full_path, file|
    machine.mkdir("dir_name" => File.dirname(full_path))
    unless file["is_dir"]
      machine.write_file("target_filename" => full_path, "content" => @op.dropbox_read_file("path" => file["path"]))
    end
    
    #machine.allow_access_for_apache("file_name" => File.dirname(full_path))
    for_the_record[full_path] = file["rev"]
    write_record.call(for_the_record) if for_the_record.size > 10
  end
  
  
  remote_files.each do |remote_file|
    path, file = remote_file.first, remote_file.last
    
    if file
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
    else
      # TODO delete local files that don't exist remote anymore
    end
    
  end
  
  write_record.call(for_the_record)
  
  # TODO this does not work if there's no apache installed
  machine.allow_access_for_apache("file_name" => params["directory"])
end
