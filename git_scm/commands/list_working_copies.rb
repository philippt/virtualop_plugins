description "returns a list of working copies found on this machine"

param :machine

mark_as_read_only

add_columns [ :path, :name ]

on_machine do |machine, params|
  result = []
  [ '$HOME', '/var/www', '$HOME/workspace', '$HOME/Dropbox', '$HOME/Dropbox/projects' ].each do |dir_name|
    next unless machine.file_exists("file_name" => dir_name)
    
    machine.ssh_and_check_result("command" => "find #{dir_name} -maxdepth 2 -type d -name .git").each do |row|

      parts = row.strip.split("/")
      parts.pop
      corrected_path = parts.join("/")
      
      result << {
        "path" => corrected_path,
        "name" => parts.last
      }
    end
    
  end
  result    
end 