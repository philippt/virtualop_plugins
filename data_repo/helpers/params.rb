def param_data_repo(options = {})
  merge_options_with_defaults(options, {
    :autofill_context_key => 'data_repo',
  })
  param_data_repo_without_context(options)
end

def param_data_repo_without_context(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_data_repos.map { |x| x["alias"] }
    end
  })
  RHCP::CommandParam.new("data_repo", "the data repository to work with", options)
end

def param_data_repo_service(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do
      @op.list_services_in_repo
    end
  })
  RHCP::CommandParam.new("data_repo_service", "a service existing in the selected data repo", options)
end

def param_data_repo_backup_for_service(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|
      @op.list_backups_in_repo("data_repo_service" => request.get_param_value("data_repo_service")).map { |x| x["name"]}
    end
  })
  RHCP::CommandParam.new("backup_name", "a backup item in the data repository to work with", options)
end

def param_local_backup(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda do |request|
      @op.list_local_backups("machine" => request.get_param_value("machine")).map { |x| x["name"] }
    end
  })
  RHCP::CommandParam.new("local_backup", "a backup stored locally on the machine (as opposed to inside a data repository)", options)
end
