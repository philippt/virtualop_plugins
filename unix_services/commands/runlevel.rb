description "returns the current unix runlevel"

param :machine

on_machine do |machine, params|
  result = nil
  s = machine.ssh("command" => "runlevel")
  if matched = /(\w+)\s+(\d+)/.match(s) then
    result = matched.captures.last
  end
  if not matched
    raise "cannot parse runlevel information: '#{s}'"
  end
  result
end
