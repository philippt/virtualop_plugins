description "searches for service descriptor files in a directory, reads them and returns a summary"

param :machine
param! "directory", "the directory to search"
param "pattern", "the search pattern to use"

on_machine do |machine, params|
  result = []
  
  dir = params["directory"]
  
  machine.with_files(
    "directory" => dir, 
    "pattern" => params.has_key?('pattern') ? params['pattern'] : "*/services/*",
    "what" => lambda do |file|
      
      full_name = "#{dir}/#{file}"
      source = machine.read_file("file_name" => full_name)
      
      $logger.debug "found #{file} : ***\n#{source}\n***\n"
      name = file.split("/").first
      service = ServiceDescriptorLoader.read(name, source).services.first
      
      service["file_name"] = full_name
      service["dir_name"] = dir + "/" + name
      service["full_name"] = file.split('/').first + '/' + file.split('/').last.split(".").first
      
      result << service
    end
  )
  result
end
