param :machine
param! "path", "path to the working copy that should be used"
param 'count', '', :default_value => 5

add_columns [ :sha, :comment ]

on_machine do |machine, params|
  result = []
  begin
    result = Timeout::timeout(5) {
      log = machine.ssh('command' => "cd #{params['path']} && git log --pretty=oneline -#{params['count']}")
      log.split("\n").map do |line|
        line.chomp!
        if /^(\S+)\s(.+)$/ =~ line
          {
            'sha' => $1,
            'comment' => $2
          }
        end
      end
    }
  rescue => detail
    $logger.error("could not get git log from #{machine.name} : #{detail.message}")
  end
  result
end
