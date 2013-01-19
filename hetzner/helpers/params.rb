def hetzner_account_dropdir
    config_string("hetzner_account_dropdir", "/etc/vop/hetzner_accounts.d")
  end

def param_hetzner_account(options = {})
  param_hetzner_account_without_context(:autofill_context_key => "hetzner_account")
end

def param_hetzner_account_without_context(options = {})
  merge_options_with_defaults(options, 
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_hetzner_accounts.map do |account|
        account["alias"]
      end
    end
  )
  RHCP::CommandParam.new("hetzner_account", "the hetzner account that should be used by default", options)
end

def mark_result_failover_ips(command)
  command.result_hints[:display_type] = "table"
  command.result_hints[:overview_columns] = [ "ip", "ip_lookup", "server_ip", "server_ip_lookup", "active_server_ip", "active_server_ip_lookup", "netmask" ]
  command.result_hints[:column_titles] = [ "ip", "ip_lookup", "server_ip", "server_ip_lookup", "active_server_ip", "active_server_ip_lookup", "netmask" ]
end

def yaml_failover_row_to_rhcp(host, data_row)
  result = nil
  if data_row.has_key?('failover')
    result = data_row['failover']
    [ "ip", "server_ip", "active_server_ip" ].each do |thing|
      dig_result = host.dig({"query" => result[thing]})
      result[thing + "_lookup"] = dig_result.first["hostname"]
    end
  end
  result
end