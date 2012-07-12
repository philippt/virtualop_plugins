def with_nagios(&block)
  site = NagiosHarder::Site.new(config_string('nagios_bin_url'), config_string('nagios_user'), config_string('nagios_password'))
  site.nagios_time_format = "%m-%d-%Y %H:%M:%S"
  block.call(site)
end  