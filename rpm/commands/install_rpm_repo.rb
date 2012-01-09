description 'installs a RPM repository or key from a URL'

param :machine
param! "repo_url", "the URL to the repo, repo rpm or key", :allows_multiple_values => true

on_machine do |machine, params|
  params["repo_url"].each do |repo_url|
    matched =  /([^\/]+)\.(\w+)$/.match(repo_url)
    if matched
      case matched.captures[1]
      when "repo"
        machine.wget("url" => repo_url, "target_dir" => "/etc/yum.repos.d")
      when "rpm"
        unless (machine.ssh("command" => "rpm -qa | grep -c #{matched.captures.first}").to_i > 0)
          machine.ssh_and_check_result("command" => "rpm -Uvh #{repo_url}")
        end
      when "key"
        begin
          machine.import_rpm_key("url" => repo_url)
        rescue
          $logger.warn("could not import key from #{repo_url} - already installed?")
        end
      end
    else
      $logger.warn("don't know what to do with repo URL #{repo_url}")
    end
  end
end
