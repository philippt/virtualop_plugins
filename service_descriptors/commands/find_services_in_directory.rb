description "searches for service descriptor files in a directory, reads them and returns a summary"

param :machine
param! "directory", "the directory to search"
param "pattern", "the search pattern to use", :default_value => "*/services/*"

display_type :table

add_columns [ :dir_name, :full_name ]

#mark_as_read_only

on_machine do |machine, params|
  result = []
  
  dir = params["directory"]
  
  machine.with_files(
    "directory" => dir, 
    "pattern" => params['pattern'],
    "what" => lambda do |file|
      service = machine.read_service_descriptor("file_name" => "#{dir}/#{file}")
      service["dir_name"] = dir 
      
      parts = service["file_name"].split("/")
      idx = parts.index("services")
      offset = 1
      possible_name = parts[idx - offset]
      if possible_name == '.vop'
        offset += 1
        possible_name = parts[idx - offset]
      end
      
      service["full_name"] = possible_name + '/' + service["name"]
      
      result << service
      
    end
  )
  
  result
end
