param :machine
param! "line", "the line holding the zypper repository to install", :allows_multiple_values => true

display_type :list

on_machine do |machine, params|
  result = []
  
  existing_repos = machine.list_zypper_repos
  
  params["line"].each do |line|
    if /\.key/.match(line)
      machine.ssh("command" => "sudo rpm --import #{line}")
    else
      url, a = line.split(" ")
      unless existing_repos.map { |x| x["alias"] }.include? a
        # TODO reactivate gpg check
        machine.ssh("command" => "sudo zypper ar --no-gpgcheck #{line}")
        result << a
      end
    end
  end
  
  if result.size > 0
    @op.without_cache do
      machine.list_zypper_repos
    end
  end
  
  result
end
