param :machine

param! "svn_url", "the URL to the subversion repo that should be checked out"

param "username"
param "password"

param :subversion, "a stored server configuration to user for authentication", :mandatory => false

param "directory", "target directory"

on_machine do |machine, params|
  auth = ' --non-interactive '
  
  config = nil
  if params.has_key?('username') && params.has_key?('password')
    auth += " --username #{params["username"]} --password #{params["password"]}"
  elsif params.has_key?('subversion')
    config = @op.list_subversion_servers.select { |x| x["alias"] == params["subversion"] }.first
    auth += " --username #{config["user"]} --password #{config["password"]}"
  end
  
  dir = ''
  if params.has_key?("directory")
    dir = params["directory"]
  end
  
  svn_url = params['svn_url']
  if config && (/^(http|svn)/ !~ svn_url)  
    svn_url = "#{config['url']}/#{svn_url}"
  end
  
  machine.ssh "svn co #{auth} #{svn_url} #{dir}"
end
