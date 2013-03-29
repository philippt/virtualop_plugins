description 'reads a file containing URLs to RPM repositories or keys and imports them'

param :machine
param "file_name", "the file to read from", :mandatory => true

display_type :list

on_machine do |machine, params|
  result = []
  input = machine.ssh("command" => "cat #{params["file_name"]}")
  input.split("\n").each do |line|
    machine.install_rpm_repo("repo_url" => line)
    result << line
  end
  result
end
