description 'adds a new repository to the apt sources list (or a public key for a repo)'

param :machine
param! "repo_url", "the URL to the key to import or the line for the sources list", :allows_multiple_values => true

on_machine do |machine, params|
  
  params["repo_url"].each do |repo_url|
    matched = /^deb/.match(repo_url)
    if matched       
      machine.ssh("command" => "echo \"#{repo_url}\" >> /etc/apt/sources.list", "user" => "root")
    else
      # lines ending on .<something>  
      matched =  /([^\/]+)\.(\w+)$/.match(repo_url)
      if matched
        case matched.captures[1]    
        when "key"
          begin
            machine.ssh("user" => "root", "command" => "wget -q -O - #{repo_url} | apt-key add -")
            #machine.import_apt_repo_key("url" => repo_url)
          rescue
            $logger.warn("could not import key from #{repo_url} - already installed?")
          end
        end
      else
        $logger.warn("don't know what to do with repo URL #{repo_url}")
      end
    end
  end
  
  machine.ssh("user" => "root", "command" => "apt-get update")
end
