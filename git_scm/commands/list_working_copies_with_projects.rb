description 'returns all git working copies found in the home directory'

param :machine

mark_as_read_only

add_columns [ :path, :name, :project, :path ]

#include_for_crawling

on_machine do |machine, params|
  result = []
  machine.list_working_copies.each do |wc|
    begin
      result << machine.working_copy_details("working_copy" => wc["name"])
    rescue Exception => detail
      $logger.warn("could not get details about #{name} : #{detail.message}")
    end    
  end
  result
end  