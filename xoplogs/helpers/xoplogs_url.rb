def xoplogs_url
  details = @op.service_details("machine" => config_string('xoplogs_machine'), "service" => "xoplogs/xoplogs")
  domain = details["domain"]
  # TODO snafu
  if domain.is_a? Array
    domain = domain.first
  end
  'http://' + domain
end