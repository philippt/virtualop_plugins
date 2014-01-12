description "lists the remote repositories configured for this working copy"

param :machine
param :working_copy

add_columns [ :name, :fetch, :push ]

mark_as_read_only

on_machine do |machine, params|
  details = machine.working_copy_details(params)
  result = []
  machine.ssh("command" => "cd #{details["path"]} && git remote show").split("\n").each do |remote|
    remote.chomp!
    h = {
      "name" => remote
    }     
    begin
      machine.ssh("command" => "cd #{details["path"]} && git remote show #{remote}").split("\n").each do |line|
        line.chomp!
        if matched = /(Fetch|Push)\s+URL:\s+(.+)/.match(line)
          h[matched.captures.first.downcase] = matched.captures.last
        end
      end
    rescue => detail
      $logger.warn("could not fetch remote config : #{detail.message}")
    end
    result << h
  end
  result
end
