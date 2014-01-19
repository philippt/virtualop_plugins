description "returns information about a working copy"

param :machine
param :working_copy

#mark_as_read_only

display_type :hash

contributes_to :working_copy_details

on_machine do |machine, params|
  wc = machine.list_working_copies.select do |w|
    w["name"] == params["working_copy"]
  end.first
  path = wc["path"]
  
  if wc["type"].split(',').include? "git"  
    remote_origin = ""
    project = ""
    begin
      machine.ssh("command" => "cd #{path} && git remote -v").split("\n").each do |line|
        matched = /origin\s+(.+)/.match(line)
        if matched
          remote_origin = matched.captures.first
          matched_again = /github.com[\:\/]([^\/]+\/.+)\.git/.match(remote_origin)
          if matched_again
            project = matched_again.captures.first
            wc["project"] = project
            wc["source"] = remote_origin
          else 
            $logger.warn "could not parse project name from remote origin #{remote_origin}"
          end
        end
      end
    rescue => detail
      $logger.warn("could not fetch origin information for project #{corrected_path} : #{detail}")
    end
    
    wc["active_branch"] = machine.list_branches_for_working_copy("working_copy" => params["working_copy"]).select { |x| x["active"] == "true" }.first["name"]
    #last_log = nil
    last_log = @op.working_copy_log(params).first
    if last_log
      wc['last_commit'], wc['last_commit_comment'] = last_log['sha'], last_log['comment']
    end
  end
  
  #pp wc
  wc
end
