description "adds the default password for all VMs (do NOT do this at home. seriously)"

param "machines", "the output of list_machines that should be enriched", :allows_multiple_values => true

contributes_to :enrich_machine_list

mark_as_read_only

execute do |params|
  params["machines"].map do |row|
    if row["type"] == 'vm'
      row["ssh_user"] = config_string('default_user') unless row.has_key? 'ssh_user'
      row["ssh_password"] = config_string('default_password') unless row.has_key? 'ssh_password'
    end
    row
  end
end