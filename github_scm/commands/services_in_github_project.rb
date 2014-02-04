description "returns the virtualop services found in the specified github project"

github_params
param! :github_project
param :git_branch

#mark_as_read_only

#add_columns [ :name, :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint ]

display_type :list

execute do |params|
  result = []
  
  files = @op.get_tree(params.merge({ "recursive" => 1 })).clone()
  
  params.delete("github_project")
  params.delete("git_branch")
  
  descriptor = []
  
  dotvop = files.select { |x| /^\.vop\//.match x["path"] }.sort { |x,y| x["path"] <=> y["path"] }.reverse
  if dotvop.size > 0
    descriptor = dotvop.map do |row|
      # remove the '.vop/' part
      parts = row["path"].split("/")
      parts.shift
      row["file"] = parts.join("/")
      row
    end
  end

  services = []  
  
  descriptor.each do |row|
    file = row["file"]
        
    if matched = /(.+)\.plugin$/.match(file)
      plugin_name = matched.captures.first
      $logger.info "found plugin #{plugin_name}"
    elsif matched = /services\/(.+)\.rb$/.match(file)
      services << matched.captures.first
    end
  end

  services  
end