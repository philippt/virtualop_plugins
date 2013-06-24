description "installs all gems listed in a file (same format as the output of 'gem list', please)"

param :machine
param! "lines", "lines from a package file", :allows_multiple_values => true

on_machine do |machine, params|
  gems = @op.read_gem_list("lines" => params["lines"])
  installed_gems = machine.list_installed_gems
  gems.each do |row|
    next if /^#/.match row["name"]
    $logger.info "checking for #{row["name"]}"
    existing = installed_gems.select do |candidate|
      # TODO should include version check
      candidate["name"] == row["name"]
    end
    machine.install_gem(row) unless existing.size > 0
  end        
  
  @op.without_cache do 
    machine.list_installed_gems
  end
end