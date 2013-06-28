description 'returns all virtual machines found on all hosts in all configured hetzner accounts'

mark_as_read_only

result_as :list_machines
add_columns [ :account, :host_name ]

contributes_to :find_vms
#contributes_to :list_machines, :z_index => 5
#contributes_to :enrich_machine_list

execute do |params|
  result = []
  #@op.list_machines # prefill the cache
  
  #@op.set_cookie("key" => "zindex_filter", "value" => 1)
  @op.list_all_hetzner_hosts.each do |host|
    @op.with_machine(host["name"]) do |machine|
      machine.list_vms.each do |vm|
        vm["type"] = "vm"
        vm["account"] = host["account"]
        vm["host_name"] = host["server_name"]
        result << vm 
      end 
    end
  end
  #@op.unset_cookie("key" => "zindex_filter")
  result
end
