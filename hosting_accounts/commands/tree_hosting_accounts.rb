description "goes through all hosting accounts and assembles data for a tree display"

mark_as_read_only

add_columns [ :name, :parent, :path ]

contributes_to :list_machine_groups

execute do |params|
  result = []
  @op.list_hosting_accounts.each do |account|
    result << {
      "path" => "/" + account["alias"],
      "name" => account["alias"],
      "parent" => "root"
    }
    result += @op.list_account_entries("hosting_account" => account["alias"]).map do |entry|
      entry["parent"] = account["alias"]
      entry["path"] = '/' + [ account["alias"], entry["name"] ].join("/")
      entry
    end
  end
  
  result.each do |group|
    if group["type"] == "host"
      begin
        status = Timeout::timeout(15) {
          result += @op.list_vms("machine" => group["name"]).map do |vm_entry|
            vm_entry["parent"] = group["name"]
            vm_entry["path"] = group["path"] + '/' + vm_entry["name"]
            vm_entry["short_name"] = vm_entry["name"]
            vm_entry["name"] = vm_entry["full_name"] 
            vm_entry["type"] = "vm"
            vm_entry
          end
        }
      rescue => detail
        $logger.warn("couldn't get VMs for host #{group["name"]} : #{detail.message}")        
      end
    end
  end
  
  result
end
