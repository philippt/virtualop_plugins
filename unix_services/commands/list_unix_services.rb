description "lists all unix services (i.e. scripts in /etc/init.d)"

param :machine

mark_as_read_only

add_columns [ :name, :state0, :state1, :state2, :state3, :state4, :state5, :state6 ]

def extract_state(state_string, collected_states, paranoia_counter = 0)
  if paranoia_counter > 10
    $logger.error("parsing states for more than 10 runlevels...either you're running a really interesting OS, or something is wrong here.")
    return
  end
  $logger.debug "states : #{state_string}"
  state_match = /(\d)\:(on|off)\s*(.*)/.match(state_string)
  if state_match
    collected_states[state_match.captures[0]] = state_match.captures[1]
    states = state_match.captures[2]
    if states != ""
      extract_state(states, collected_states, paranoia_counter += 1)
    end
  end
end

on_machine do |machine, params|
  result = []
      
  services = machine.ssh_and_check_result(
    #'user' => 'root',
    'command' => 'chkconfig --list'
  )
  services.split("\n").each do |line|
    # acpid           0:off   1:off   2:on    3:on    4:on    5:on    6:off
    matched = /(\S+)\s+(.+)/.match(line)
    if matched
      collected_states = {}
      states = matched.captures[1]

      extract_state(states, collected_states)
      
      result << {
        "name" => matched.captures[0]
      }
      collected_states.each do |runlevel, state|
        result.last["state#{runlevel}"] = state
      end
    else
      $logger.error("unexpected line : #{line}")
    end
  end

  result
end