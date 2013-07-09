description "returns a list of working copies found on this machine"

param :machine

mark_as_read_only

#contributes_to :list_working_copies
result_as :list_working_copies

on_machine do |machine, params|
  raise "this code has been moved into list_working_copies"
  result = []
  home = machine.home
  [ home, '/var/www', "#{home}/workspace", "#{home}/Dropbox", "#{home}/Dropbox/projects" ].each do |dir_name|
    next unless machine.file_exists("file_name" => dir_name)
    
    begin
      #TODO machine.ssh("command" => "find #{dir_name} -maxdepth 2 -type d -name .git -or -name .vop").each do |row|
      working_copies = machine.find("path" => dir_name, "maxdepth" => "2", "type" => "d", "name" => ".git")
      
      working_copies.each do |row|
        parts = row.strip.split("/")
        parts.pop
        corrected_path = parts.join("/")
        
        result << {
          "path" => corrected_path,
          "name" => parts.last,
          "type" => "git"      
        } unless result.select { |x| x["path"] == corrected_path }.size > 0
      end
    rescue => detail
      if /Permission denied/.match(detail.message)
        $logger.warn("could not access #{dir_name} due to a permissions issue")
      else
        raise
      end 
    end
    
  end
  result    
end 