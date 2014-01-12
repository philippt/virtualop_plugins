description "renames a VM (config file and storage pool)"

param :machine
param :vm
param! "new_name", "the name for the new VM"

on_machine do |machine, params|
  xml_file_name = libvirt_config_file(params)
  parts = xml_file_name.split("/")
  parts.pop
  new_file_name = (parts + [ params["new_name"] + '.xml' ]).join("/")
  
  machine.ssh("command" => "cp #{xml_file_name} #{new_file_name}")
  
  machine.replace_in_file("file_name" => new_file_name, "source" => params["name"], "target" => params["new_name"])

  old_volume_definition = machine.ssh("command" => "virsh vol-dumpxml --pool default #{params["name"]}.img")
     
  old_volume = XmlSimple.xml_in(old_volume_definition)
  #pp old_volume
  old_path = old_volume["target"].first["path"].first
  parts = old_path.split("/")
  parts.pop
  new_path = (parts + [ params["new_name"] + '.img' ]).join("/") 
  
  #@op.comment("message" => "mv #{old_path} #{new_path}")
  machine.ssh("command" => "mv #{old_path} #{new_path}")
  machine.ssh("command" => "touch #{old_path}")
  
  #new_volume = old_volume.clone()
  #new_volume["target"].first["path"] = [ new_path ]
  #new_volume["key"] = [ new_path ]
  #new_volume["name"] = [ "#{params["new_name"]}.img" ]
  
  #tempfile_name = '/tmp/virtualop_libvirt_storage_definition_' + new_path
  #machine.write_file("target_filename" => tempfile_name, "content" => XmlSimple.xml_out(new_volume, { 'RootName' => 'volume' }))
  
  #machine.ssh("command" => "virsh vol-create --pool default #{tempfile_name}")
  
  machine.ssh("command" => "cd /var/lib/virtualop/machines && cp #{params["name"]} #{params["new_name"]}")
  machine.replace_in_file("file_name" => "/var/lib/virtualop/machines/#{params["new_name"]}", "source" => params["name"], "target" => params["new_name"])
  
  machine.terminate_vm("name" => params["name"])
  
  machine.ssh('command' => 'virsh define ' + new_file_name)
end 