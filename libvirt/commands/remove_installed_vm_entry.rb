description "removes an entry from the list of installed vms (shouldn't do this)"

param :machine
param "name", "the name of the vm entry that should be removed", :mandatory => true
param "cache_update", "if set to false, will not update cached date"

on_machine do |machine, params|
  dir_name = "/var/lib/virtualop/machines/"      
  machine.rm("file_name" => "#{dir_name}#{params["name"]}")
  
  unless params.has_key?("cache_update") && params["cache_update"] == "nothx"
    @op.without_cache do
      machine.list_installed_vms()
    end
  end
end
