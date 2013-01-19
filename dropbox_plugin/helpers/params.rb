def param_dropbox_token(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :allows_multiple_values => true, 
    :autofill_context_key => 'dropbox_token'
  })
  RHCP::CommandParam.new("dropbox_token", "the dropbox token (array of key + secret) to be used", options)
end

def param_dropbox_project(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda {
      @op.list_dropbox_projects.map { |x| x["name"] }
    }
  })
  RHCP::CommandParam.new("project", "the dropbox project to write into", options)
end