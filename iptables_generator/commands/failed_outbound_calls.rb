param :machine

display_type :list

on_machine do |machine, params|
  machine.forward_drops.select do |line|
    /SRC=10\./.match(line)
  end
end
