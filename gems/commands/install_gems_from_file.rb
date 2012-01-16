description "installs all gems listed in a file (same format as the output of 'gem list', please)"

param :machine
param "file_name", "absolute path to the file containing the gem names/versions", :mandatory => true

on_machine do |machine, params|
  content = machine.ssh_and_check_result("command" => "cat #{params["file_name"]}")
  gems = @op.read_gem_list("input" => content)
  installed_gems = machine.list_installed_gems
  gems.each do |row|
    $logger.info "checking for #{row["name"]}"
    existing = installed_gems.select do |candidate|
      # TODO should include version check
      candidate["name"] == row["name"]
    end
    machine.install_gem(row) unless existing.size > 0
  end        
end