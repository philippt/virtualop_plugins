description "returns a list of services that can be installed on machines"

execute do |params|
  @op.with_machine("localhost") do |localhost|
    config_string("descriptor_dirs").each do |dir|
      localhost.with_files(
        "directory" => dir, 
        "pattern" => "*/services/*",
        "what" => lambda do |file|
          puts "found #{file}"
        end
      )
    end
  end
end
