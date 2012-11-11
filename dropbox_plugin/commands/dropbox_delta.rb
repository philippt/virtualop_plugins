param :dropbox_token

param :machine, "a machine to sync the changes to", :mandatory => false
param :working_copy, "the working copy which should be kept in sync", :mandatory => false

execute do |params|
  with_dropbox(params) do |client|
    cursor = nil
    
    while (true) do
      result = client.delta(cursor)
      puts "found #{result["entries"].size} delta entries"
      pp result["entries"] if result["entries"].size > 0
      
      changes = {
        :files => {},
        :projects => {}
      }
      result["entries"].each do |entry|
        path, metadata = entry.first, entry.last
        puts "#{path}\t#{metadata}"
        
        if matched = /\/projects\/([^\/]+)$/.match(path)
          project_name = $1
          #puts "PROJECT_CHANGE #{project_name} #{metadata["rev"]}"
          changes[:projects][project_name] = [ path, metadata ]
        elsif matched = /\/projects\/([^\/]+)\/(.+)$/.match(path)
          project_name, rel_path = $1, $2
          #puts "PROJECT_FILE_MODIFICATION [#{project_name}] #{rel_path} #{metadata["rev"]}"
          changes[:files][project_name] = [] unless changes[:files].has_key? project_name
          changes[:files][project_name] << [ path, metadata ]
        end
      end
      
      if cursor != nil # suppress startup # TODO actually, we should probably process the startup as well
        if changes[:projects].size > 0
          @op.initialize_new_dropbox_projects()
        end 
        #changes[:projects].each do |project_name, change|
        #end
        
        if params.has_key?("machine")
          @op.with_machine(params["machine"]) do |machine|
            machine.list_dropbox_working_copies.each do |working_copy|
              project_name = working_copy["name"]
              if changes[:files].has_key? project_name
                machine.sync_dropbox_folder(
                  "path" => "/projects/#{project_name}", 
                  "directory" => working_copy["path"], 
                  "remote_files" => changes[:files][project_name]
                )
              end                             
            end
          end
        end
      end
      
      cursor = result["cursor"]
      
      sleep_time = result["has_more"] ? 0 : 15
      sleep sleep_time
    end    
  end
end