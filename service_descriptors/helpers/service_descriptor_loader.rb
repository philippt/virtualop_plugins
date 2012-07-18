class ServiceDescriptorLoader
  
  attr_reader :services
  
  def initialize(op)
    @op = op
    @services = []
    
    #@command_loader = CommandLoader.new()
  end
  
  def new_service(name)
    @service = { "name" => name }
    @services << @service
    
    install_command_name = "#{name}_install"
    broker = @op.local_broker
    install_command = nil
    begin
      install_command = broker.get_command(install_command_name)
      $logger.info("found install command #{install_command.name}")
      @service["install_command_name"] = install_command.name
      @service["install_command_params"] = install_command.params
    rescue Exception => e
      $logger.info("did not find install_command #{install_command_name} : #{e.message}")
      @service["install_command_name"] = nil
    end
    
    @service
  end
  
  def runlevel(sym)
    @service["runlevel"] = sym.to_s
  end
  
  def method_missing(m, *args)
    targets = [ :unix_service, :run_command, :redirect_log, :cron, :start_command, :stop_command, :port, :process_regex, :http_endpoint, :tcp_endpoint, :log_file, :on_install ]
    #targets += [ :runlevel ]
    
    if targets.include? m
      @service[m.to_s] = *args.first
    else
      #if [ :param, :param!, :params_as ].include? m
        #@service.install_command
      #end
      super(m, args)
    end
  end
  
  def self.read(op, name, source)
    loader = new(op)

    loader.new_service(name)
    loader.instance_eval source

    loader
  end
  
end