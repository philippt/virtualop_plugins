contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  type = source = version = 'unknown'  
  if service.has_key?('extra_params') && service['extra_params']
    if service['extra_params'].has_key?('github_project')
      type = 'github'
      source = service['extra_params']['github_project']
      if service['extra_params'].has_key?('git_branch')
        version = service['extra_params']['git_branch']
      end
    end
  end
  
  @op.comment "tracking deployment of service #{service['full_name']} from #{source} (v #{version}) onto #{machine.name}"
  begin
    Deployment.new(:source_type => type, :source => source, :version => version, :machine => machine.name).save
  rescue => detail
    $logger.error("could not track deployment through Rails - maybe you want to use rails_vop instead of vop? error detail : #{detail.message}")
    raise detail
  end  
end