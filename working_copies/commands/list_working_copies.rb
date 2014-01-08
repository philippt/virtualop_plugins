description "working copies are projects living on machines"

param :machine
param "type", "filter by type"

mark_as_read_only

add_columns [ :path, :name, :type ]

#include_for_crawling

with_contributions do |result, params|
  result = []

  locations = config_string('location').dup

  @op.with_machine(params["machine"]) do |machine|  
    locations << machine.home
    locations.each do |dir_name|
      next unless machine.file_exists("file_name" => dir_name)
      
      begin
        #puts "known metadata dirs : "
        #pp config_string('known_metadata_dirs')
        
        config_string('known_metadata_dirs').each do |known_metadata_dir|      
          find_params = { 
            "path" => dir_name, 
            "type" => "d", 
            "follow" => (config_string('follow_symlinks').to_s == 'true').to_s, 
            "maxdepth" => config_string('find_maxdepth'), 
            "name" => [ known_metadata_dir ] 
          }
          if @plugin.config.has_key?('path_blacklist')
            find_params["exclude_path"] = config_string('path_blacklist')
          end
          working_copies = machine.find(find_params)
          
          working_copies.each do |row|
            parts = row.strip.split("/")
            parts.pop
            corrected_path = parts.join("/")
            
            result << {
              "path" => corrected_path,
              "name" => parts.last,
              "type" => (/^\.(.+)/ =~ known_metadata_dir ? $1 : known_metadata_dir)       
            }
          end
        end
      rescue => detail
        if /Permission denied/.match(detail.message)
          $logger.warn("could not access #{dir_name} due to a permissions issue")
        else
          raise
        end 
      end
      
    end
    
    # filter link targets
    link_targets = []
    result.each do |row|
      begin
        path = row['path']
        if /symbolic link/.match(machine.ssh("file #{path}"))
          link_targets << machine.ssh("readlink #{path}").chomp
        end
      rescue => detail
        $logger.info("#{row['path']} is probably not a link : #{detail.message}")
      end
    end
    link_targets.each do |target|
      $logger.info("removing link targets ending in '#{target}'")
      result.delete_if { |x| /#{target}$/ =~ x['path']}
    end
    
    # remove home (it's not a working copy, even though there might be a .vop subdirectory thanks to one stupid son of a bitch)
    result.delete_if { |x| x['path'] == machine.home }
  end # with_machine
  
  if params.has_key?("type")
    result.delete_if { |x| x["type"] != params["type"] }
  end
  
  # make result unique by path, merging types
  result.each do |row|
    same_path = result.select { |x| x["path"] == row["path"] }.delete_if { |x| x == row }
    same_path.each do |moriturus|
      if row.has_key?("type") and moriturus.has_key?("type")
        row["type"] += ',' + moriturus["type"]        
      end
      result.delete moriturus      
    end
  end
  
  
  result    
end  
