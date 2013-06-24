param :machine

on_machine do |vm, params|
  target_file_name = '/etc/yum.repos.d/CentOS-Base.repo'
  
  vm.rm("file_name" => target_file_name) if vm.file_exists("file_name" => target_file_name)
  
  full_url = @op.plugin_by_name("vm_handling").config_string("install_kernel_location")
  mirror_base = full_url[0..full_url.index('/', 10)-1]
    
  process_local_template(:centos_base_repo, vm, target_file_name, binding())
end