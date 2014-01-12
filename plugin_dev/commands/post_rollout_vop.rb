param! 'vop_machine'

accept_extra_params

execute do |params|
  params.merge! params['extra_params'] if params['extra_params']
  
  @op.with_machine(params['vop_machine']) do |vop|
    vop.as_user('marvin') do |marvin|
      @op.flush_cache # TODO #snafoo machine.home is cached as '/root'
      marvin.upload_stored_keypair("keypair" => params["keypair"])
      marvin.transfer_keypair("keypair" => params["keypair"])
      @op.comment "uploaded and transferred keypair #{params['keypair']}"
      
      params["hetzner_account"].each do |hetzner_account|
        marvin.upload_hetzner_account("hetzner_account" => hetzner_account)
        @op.comment "uploaded hetzner account #{hetzner_account}"
      end      
      
      marvin.vop_call("force" => "true", "command" => "find_vms", "logging" => "true")
      
      marvin.upload_data_repo("target_alias" => "old_data_repo")
      
      if params["clone"]
        identity = @op.whoareyou.split('@').last
        @op.with_machine(identity) do |me|
          me.backup_data()
        end
      end
      # TODO marvin.vop_call("logging" => "true", "command" => "restore_self")
      
      # TODO execute migrations (happens inside restore_self at the moment)
      
      p = {}
      p.merge_from params, :github_token
      p.merge! params['extra_params'] if params['extra_params']
      
      p['stack'] = 'minimal_platform'
      p['host'] = params["machine"]
      
      marvin.vop_call( 
        "command" => "start_rollout",
        "extra_params" => p,
        "force" => "true", 
        "logging" => "true" 
      )
    end
  end
end  
