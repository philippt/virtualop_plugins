class ServiceDescriptorLoader
  
  attr_reader :services
  
  def initialize(op, plugin)
    @op = op
    @plugin = plugin
    @services = []
    
    plugin.load_helper_classes(self) unless plugin == nil
    
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
      $logger.debug("did not find install_command #{install_command_name} : #{e.message}")
      @service["install_command_name"] = nil
    end
    
    @service["databases"] = []
    @service["local_files"] = []
    @service["outgoing_tcp"] = []
    
    @service["nagios_checks"] = {}
    @service["tcp_endpoint"] = []
    @service["udp_endpoint"] = []
    
    @service
  end
  
  def runlevel(sym)
    @service["runlevel"] = sym.to_s
  end
  
  def database(name, options = { :mode => 'read-write', :exclude_tables => [], :include_tables => [] })
    options[:name] = name
    # TODO cleanup
    options.each do |k,v|
      options[k.to_s] = v
    end
    @service["databases"] << options
  end
  
  def backup(hash, mode = 'read-write')
    hash.each do |k,v|
      case v.class.to_s
      when "String"
        @service["local_files"] << {
          "alias" => k.to_s,
          "path" => v,
          "mode" => mode
        }
      when "Hash"
        v["alias"] = k.to_s
        @service["local_files"] << v
      end
    end
  end
  
  def outgoing_tcp(sym)
    @service["outgoing_tcp"] << sym.to_s
  end
  
  def unix_service(arg)
   @service["unix_service"] = arg
  end
  
  def run_command(command, options = {})
    @service["run_command"] = command
    if options.size > 0
      options.each do |k,v|
        @service["run_command.#{k}"] = v
      end
    end 
  end
  
  def nagios_check(check_hash)
    @service["nagios_checks"].merge! check_hash
  end
  
  def post_restart(&block)
    @service["post_restart"] = lambda do |machine, params|
      block.call(machine, params)
    end
  end
  
  def post_installation(&block)
    @service["post_installation"] = lambda do |machine, params|
      block.call(machine, params)
    end
  end
  
  def tcp_endpoint(t)
    if t.class == Array
      @service["tcp_endpoint"] += t
    else
      @service["tcp_endpoint"] << t
    end
  end
  
  def udp_endpoint(t)
    if t.class == Array
      @service["udp_endpoint"] += t
    else
      @service["udp_endpoint"] << t
    end
  end
  
  def method_missing(m, *args)
    targets = [ :redirect_log, :start_command, :stop_command, :on_install ]
    targets += [ :port, :process_regex, :log_file ]
    targets += [ :cron, :every ]
    targets += [ :http_endpoint ]
    targets += [ :static_html ]
    #targets += [ :database ]
    #targets += [ :runlevel ]
    
    if targets.include? m
      @service[m.to_s] = *args.first
      #@service[m] = *args.first
    else
      #if [ :param, :param!, :params_as ].include? m
        #@service.install_command
      #end
      super(m, args)
    end
  end
  
  def self.read(op, plugin, name, source)
    loader = new(op, plugin)

    loader.new_service(name)
    loader.instance_eval source

    loader
  end
  
end