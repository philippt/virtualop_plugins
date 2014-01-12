def param_keypair(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_stored_keypairs.map { |x| x["alias"] }
    end
  })
  RHCP::CommandParam.new("keypair", "a stored SSH keypair to be used", options)
end
