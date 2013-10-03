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
          working_copies = machine.find("path" => dir_name, "maxdepth" => "2", "type" => "d", "name" => [ known_metadata_dir ])
          
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
  end
  
  if params.has_key?("type")
    result.delete_if { |x| x["type"] != params["type"] }
  end
  
  # make result unique by path, merging types?
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
