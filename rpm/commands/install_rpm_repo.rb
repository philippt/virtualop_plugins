description 'installs a RPM repository or key from a URL'

param :machine
param! "repo_url", "the URL to the repo, repo rpm or key", :allows_multiple_values => true

on_machine do |m, params|
  m.as_user("user_name" => "root") do |machine|
    params["repo_url"].each do |repo_url|
      matched =  /([^\/]+)\.(\w+)$/.match(repo_url)
      if matched
        case matched.captures[1]
        when "repo"
          machine.wget("url" => repo_url, "target_dir" => "/etc/yum.repos.d")
        when "rpm"
          r = machine.ssh_extended("command" => "rpm -qa | grep -c #{matched.captures.first}")
          unless r["result_code"] == 0 && r["output"].to_i > 0
            begin
              machine.ssh("command" => "rpm -Uvh #{repo_url}")
            rescue => detail
              pp detail
              raise unless /is already installed/ =~ detail.message
            end
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
end
