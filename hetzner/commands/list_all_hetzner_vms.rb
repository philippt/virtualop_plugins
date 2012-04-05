description 'returns all virtual machines found on all hosts in all configured hetzner accounts'

mark_as_read_only

display_type :table
add_columns [ :account, :host_name ]

contributes_to :find_vms

execute do |params|
  result = []
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
  result
end
