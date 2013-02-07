param :machine
param! "line", "the line holding the zypper repository to install", :allows_multiple_values => true

display_type :list

on_machine do |machine, params|
  result = []
  
  existing_repos = machine.list_zypper_repos
  
  params["line"].each do |line|
    url, a = line.split(" ")    
    unless existing_repos.map { |x| x["alias"] }.include? a
      machine.ssh_and_check_result("command" => "zypper ar #{line}")
      result << a
    end
  end
  
  if result.size > 0
    @op.without_cache do
      machine.list_zypper_repos
    end
  end
  
  result
end
