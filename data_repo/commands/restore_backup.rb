description "restores a database or local directory from the specified backup"

param :machine
param :local_backup
param :service

on_machine do |machine, params|
  the_backup = @op.decode_backup_filename("filename" => params["local_backup"]).first
  @op.comment("message" => "restoring backup from data repo: #{the_backup["name"]}")
 
  if the_backup["type"] == "file" then
    
    # TODO not quite
    service = machine.service_details("service" => params["service"])
    candidates = service["local_files"].select { |x| x["alias"] == the_backup["alias"] }
    raise "the service #{the_backup["service"]} on #{machine.name} does not seem to have a local files definition with alias '#{the_backup["alias"]}'" unless candidates.size > 0
    local_files = candidates.first    
    local_directory = /^\//.match(local_files["path"]) ? local_files["path"] : service["service_root"] + '/' + local_files["path"]
    
    $logger.info "restoring backup #{the_backup["name"]} into #{local_directory}"
    
    machine.mkdir "dir_name" => local_directory
    machine.untar "working_dir" => local_directory, "tar_name" => local_backup_dir(machine) + '/' + the_backup["name"] + '.tgz'
    
    new_owner = nil
    if local_files.has_key?("owner")
      new_owner = local_files["owner"]
    elsif @plugin.config.has_key?('default_owner')
      new_owner = @plugin.config['default_owner']
    end
    if new_owner != nil
      machine.ssh("user" => "root", "command" => "chown -R #{new_owner} #{local_directory}")
    end
     
    new_permissions = nil
    if local_files.has_key?("permissions")
      new_permissions = local_files["permissions"]
    elsif @plugin.config.has_key?('default_permissions')
      new_permissions = @plugin.config['default_permissions']
    end
    if new_permissions != nil
      machine.ssh("user" => "root", "command" => "chmod -R #{new_permissions} #{local_directory}")
    end  
    
  elsif the_backup["type"] == "db" then
    machine.restore_dump("dump_name" => the_backup["name"])
  end
  
  the_backup
end    
