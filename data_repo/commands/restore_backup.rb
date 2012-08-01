description "restores a database or local directory from the specified backup"

param :machine
#param :mysql_host
param :local_backup

on_machine do |machine, params|
  the_backup = @op.decode_backup_filename("filename" => params["local_backup"]).first
  @op.comment("message" => "restoring backup from data repo: #{the_backup["name"]}")
 
  if the_backup["type"] == "file" then
    
    service = machine.service_details("service" => the_backup["service"])
    #pp service["local_files"]
    candidates = service["local_files"].select { |x| x["alias"] == the_backup["alias"] }
    raise "the service #{the_backup["service"]} on #{machine.name} does not seem to have a local files definition with alias '#{the_backup["alias"]}'" unless candidates.size > 0
    #pp candidates.first
    local_directory = service["service_root"] + '/' + candidates.first["path"]
    
    $logger.info "restoring backup #{the_backup["name"]} into #{local_directory}"
    
    machine.mkdir "dir_name" => local_directory
    machine.untar "working_dir" => local_directory, "tar_name" => local_backup_dir(machine) + '/' + the_backup["name"] + '.tgz'
    
    # TODO add file ownership & permissions:
    # if @plugin.config.has_key?('default_owner')
      # new_owner = @plugin.config['default_owner']
      # machine.ssh_and_check_result("user" => "root", "command" => "chown -R #{new_owner} #{local_directory}")
    # end
#     
    # if @plugin.config.has_key?('default_permissions')
      # new_permissions = @plugin.config['default_permissions']
      # machine.ssh_and_check_result("user" => "root", "command" => "chmod -R #{new_permissions} #{local_directory}")
    # end
  elsif the_backup["type"] == "db" then
    machine.restore_dump("dump_name" => the_backup["name"])
  end
  
  the_backup
end    
