github_params

param :machine
param :keypair
param 'tag', 'name of the tag that should be attached to this version', :default_value => 'stable'
param 'comment', 'comment for the tag', :default_value => 'this tag was created automatically (no animals have been harmed in the process)'

on_machine do |machine, params|
  @op.prepare_github_ssh_connection(params)
  
  machine.list_working_copies.each do |wc|
    name = wc["name"]
    details = machine.working_copy_details("working_copy" => name)
    if details.has_key?("project") && details["project"].split("/").first == "virtualop"
      machine.switch_to_ssh("working_copy" => name)
      machine.tag_working_copy("force" => "true", "working_copy" => name, 
        "tag" => params['tag'], 
        "comment" => params['comment']
      )
    end
  end
end  
