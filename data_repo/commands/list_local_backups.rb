description "lists all local backups of database or local file directories"

param :machine

mark_as_read_only

response_type_backup

on_machine do |machine, params|
  result_by_name = {}

  dump_dir = local_backup_dir(machine)
  if machine.file_exists("file_name" => dump_dir)  
    machine.list_files("directory" => dump_dir).each do |dump_file_name|
      next unless matched = /(.+)\.tgz$/.match(dump_file_name)          
      the_backup = @op.decode_backup_filename "filename" => dump_file_name
      if the_backup.size > 0 then
        result_by_name[the_backup.first["name"]] = the_backup.first
      end
    end
  end
  
  result = result_by_name.values
  result.sort! { |x,y| x["date"] <=> y["date"] }
  result
end  
