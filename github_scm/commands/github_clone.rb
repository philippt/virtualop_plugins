description 'clones a project from github onto a machine'

github_params

param :machine

param! "github_project", :default_param => true
param :git_branch
param :git_tag
param "directory", "the target directory to checkout into (defaults to $HOME/project_name)"
param "force", "set (to any value) if you want to override existing target directories"

on_machine do |machine, params|
  git_url = "https://github.com/#{params["github_project"]}.git"
  
  if has_github_params(params)    
    begin
      project_row = @op.list_github_repos(params).select { |x| x["full_name"] == params["github_project"] }.first
      if project_row != nil && project_row["private"] == true
        git_url = "git@github.com:#{params["github_project"]}.git"
      end
    rescue Exception => detail
      raise detail unless /^need either/.match(detail.message)
    end
  end
      
  clone_params = {
    "git_url" => git_url
  }.merge_from params, :git_tag, :git_branch, :directory, :force
  machine.git_clone(clone_params)  
end
