description "modifies the configuration of all 'virtualop' working copies to use ssh instead of git as transport layer"

param :machine

on_machine do |machine, params|
  machine.write_keys
  machine.list_working_copies.each do |wc|
    name = wc["name"]
    details = machine.working_copy_details("working_copy" => name)
    if details["project"].split("/").first == "virtualop"
      machine.switch_to_ssh("working_copy" => name)
      machine.tag_working_copy("force" => "true", "working_copy" => name, "tag" => "stable", "comment" => "passed CI #{Time.now.strftime("%Y%m%d")} on #{machine.name}")
    end
  end
end  
