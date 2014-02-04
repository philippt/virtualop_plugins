description "adds all known hetzner hosts to the list of known machines."

#contributes_to :find_hosts

execute do |params|
  @op.list_all_hetzner_hosts.each do |row|
    @op.add_known_machine(
      "ssh_host" => row["ssh_name"],
      "ssh_port" => row["ssh_port"],
      "ssh_user" => row["ssh_user"],
      "name" => row["name"],
      "type" => "host"      
    )
  end
end

