description 'returns all git working copies found in the home directory'

param :machine

mark_as_read_only

add_columns [ :project, :path ]

on_machine do |machine, params|
  # TODO refactor (moved into list_working_copies) or kill
  result = []
  [ '$HOME', '/var/www', '$HOME/workspace', '$HOME/Dropbox', '$HOME/Dropbox/projects', '/etc/vop/service_descriptors' ].each do |dir_name|
    next unless machine.file_exists("file_name" => dir_name)
    machine.ssh_and_check_result("command" => "find #{dir_name} -maxdepth 2 -type d -name .git").each do |row|

      parts = row.strip.split("/")
      parts.pop
      corrected_path = parts.join("/")
      
      remote_origin = ""
      project = ""
      begin
        machine.ssh_and_check_result("command" => "cd #{corrected_path} && git remote show origin").split("\n").each do |line|
          matched = /Fetch URL:\s+(.+)/.match(line)
          if matched
            remote_origin = matched.captures.first
            matched_again = /github.com[\:\/]([^\/]+\/.+)\.git$/.match(remote_origin)
            if matched_again
              project = matched_again.captures.first
            else 
              $logger.warn("could not parse project name from remote origin #{remote_origin}")
            end
          end
        end
      rescue => detail
        $logger.warn("could not fetch origin information for project #{corrected_path} : #{detail}")
      end

      result << {
        "path" => corrected_path,
        "name" => parts.last,
        "source" => remote_origin,
        "project" => project
      }
    end    
  end
  result
end  