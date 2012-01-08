description 'returns a list of installed RPM packages'

param :machine

mark_as_read_only

#display_type :list
add_columns [ :full_string, :name, :version ]

on_machine do |machine, params|
  #ivtv-firmware-20080701-20.2.noarch
  #e2fsprogs-1.41.12-3.el6.x86_64
  result = []
  machine.ssh_and_check_result("command" => "rpm -qa").split("\n").each do |line|
    h = {
      "full_string" => line
    }
    matched = /^(.+?)-(\d+.+)/.match(line)
    if matched
      h["name"] = matched.captures[0]
      h["version"] = matched.captures[1]  
    end
    result << h
  end
  result  
end
