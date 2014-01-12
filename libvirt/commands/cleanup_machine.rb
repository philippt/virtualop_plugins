#param :machine, :allows_extra_values => true
param! "machine"

notifications

execute do |params|
  puts "cleanup #{params["machine"]}"
  parts = params["machine"].split('.')
  vm_name = parts.shift
  host_name = parts.join(".")
  
  begin
    full_name = params["machine"]
    if @op.list_known_machines.map { |x| x["name"] }.include? full_name
      @op.remove_known_machine("name" => full_name)
    end
    if @op.list_installed_vms("machine" => host_name).map { |x| x["vm_name"] }.include? vm_name
      @op.remove_installed_vm_entry("machine" => host_name, "name" => vm_name)
    end
   rescue Exception => e
     $logger.warn("could not remove machine entry : #{e.message}")
   end
end
