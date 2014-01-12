param :machine

result_as :list_vms

on_machine do |machine, params|
  # TODO locking?
  machine.list_vms.select do |vm|
    result = false
    begin
      @op.without_cache do
        result = (/^spare\d+$/.match vm["name"]) &&
          (@op.vm_status("machine" => vm["full_name"]) == "running") &&
          @op.reachable_through_ssh("machine" => vm["full_name"]) &&
          @op.file_exists("machine" => vm["full_name"], "file_name" => "/var/lib/virtualop/setup_params")
      end
    rescue => detail
      result = false
    end
    result
  end
end  
