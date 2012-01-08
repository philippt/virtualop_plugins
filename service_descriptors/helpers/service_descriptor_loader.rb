class ServiceDescriptorLoader
  
  attr_reader :services
  
  def initialize
    @services = []
  end
  
  def new_service(name)
    @service = { "name" => name }
    @services << @service
    
    @service
  end
  
  def method_missing(m, *args)
    targets = [ :unix_service, :port, :process_regex, :http_endpoint, :tcp_endpoint, :on_install ]
    
    if targets.include? m
      @service[m.to_s] = *args.first
    else
      super(m, args)
    end
  end
  
  def self.read(name, source)
    loader = new()

    loader.new_service(name)
    loader.instance_eval source

    loader
  end
  
end