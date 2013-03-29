description "returns a list of working copies found on this machine"

param :machine

mark_as_read_only

contributes_to :list_working_copies
result_as :list_working_copies

on_machine do |machine, params|
  result = []
  [ '$HOME', '/var/www', '$HOME/workspace', '$HOME/Dropbox', '$HOME/Dropbox/projects' ].each do |dir_name|
    next unless machine.file_exists("file_name" => dir_name)
    
    begin
      #TODO machine.ssh("command" => "find #{dir_name} -maxdepth 2 -type d -name .git -or -name .vop").each do |row|
      machine.find("path" => dir_name, "maxdepth" => "2", "type" => "d", "name" => ".git").each do |row|
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
      $logger.warn("could not access #{dir_name} due to a permissions issue")
      raise detail unless /Permission denied/.match(detail.message)
    end
    
  end
  result    
end 