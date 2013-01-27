description "returns the configuration fragments that should be included into the FORWARD chain"

param :machine
param! "chain", "the iptables chain to list includes for"

add_columns [ :machine, :service, :file_name ]

on_machine do |machine, params|
  chain = params["chain"]
  machine.list_files("directory" => "#{config_string('include_dropdir')}/#{chain}/").map do |x|
    matched = /(.+)_(.+)\.conf/.match x
    {
      "machine" => matched.captures[0],
      "service" => matched.captures[1],
      "chain" => chain,
      "file_name" => x
    }
  end
end
