description "lists commits on a repository"

github_params
param! :github_project
param :git_branch, "the branch to retrieve", :default_value => "master"

#display_type :hash

add_columns [ :sha ]
#display_type :list

execute do |params|
  extra_path = '&sha=' + params["git_branch"] if params.has_key?("git_branch")
  output = JSON.parse(@op.http_get("url" => "https://api.github.com/repos/#{params["github_project"]}/commits?access_token=#{params["github_token"]}#{extra_path}"))
  puts JSON.pretty_generate(output)

  output.map do |row|
    #p row    
    #row[:author] = row[:committer][:login] if row.has_key? :committer
    #row["message"] = row["commit"]["message"] if row.has_key? "commit" and row["commmit"].has_key? "message"
    row
  end
  #p result.first
  output
end  
