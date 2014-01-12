description "adds a column to list_vms called exists_on_host for all VMs"

param "machines", "the output of list_machines that should be enriched", :allows_multiple_values => true

#contributes_to :enrich_machine_list

execute do |params|
  params["machines"].map do |row|
    
    if row["type"] == "vm"
      @op.with_machine(row["host_name"]) do |host|
        host.list_vms.select do |vm|
          vm["full_name"] == row["name"]
        end
      end
    end
    
    row
  end
end