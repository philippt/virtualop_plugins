def param_hosting_account(options = {})
  merge_options_with_defaults(options, 
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_hosting_accounts.map do |account|
        account["alias"]
      end
    end
  )
  RHCP::CommandParam.new("hosting_account", "the account that should be used", options)
end