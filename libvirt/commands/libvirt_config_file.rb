param! "vm_name", "name of the vm"

execute do |params|
  "/etc/libvirt/qemu/#{params["vm_name"]}.xml"
end
