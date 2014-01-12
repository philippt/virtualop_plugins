param :machine
param :environment

on_machine do |machine, params|
  if params.has_key? 'environment'
    machine.write_file(
      'target_filename' => '/etc/profile.d/vop_env.sh', 
      'content' => "export VOP_ENV=#{params["environment"]}"
    )
  end
end