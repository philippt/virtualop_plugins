description "returns the configuration fragments that should be included into the FORWARD chain"

param :machine

add_columns [ :machine, :service, :file_name ]

on_machine do |machine, params|
  machine.list_files("directory" => "#{config_string('include_dropdir')}/forward/").map do |x|
    matched = /(.+)_(.+)\.conf/.match x
    {
      "machine" => matched.captures[0],
      "service" => matched.captures[1],
      "file_name" => x
    }
  end
end
