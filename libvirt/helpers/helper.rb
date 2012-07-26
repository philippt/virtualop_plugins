def libvirt_config_file(params)  
  "/etc/libvirt/qemu/#{params["vm_name"]}.xml"
end  