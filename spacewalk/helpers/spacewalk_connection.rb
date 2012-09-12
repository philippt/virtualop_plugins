class SpacewalkConnection

  attr_reader :server, :session 

  def initialize(connection_string)
    @uri = URI.parse(connection_string)
  
    @connected = false
  end
  
  def hostname
    @uri.host
  end

  def connect(force = false)
    if ! @connected || force
      
      spacewalk = @uri
    
      @server = XMLRPC::Client.new(spacewalk.host, '/rpc/api', spacewalk.port, nil, nil, nil, nil, true)
      @session = @server.call('auth.login', spacewalk.user, spacewalk.password)
      $logger.debug "connected to spacewalk server at '#{spacewalk.host}' as user '#{spacewalk.user}'"
      
      @connected = true
    end
  end

  def disconnect()
    if @connected
      @server.call('auth.logout', @session)
      $logger.debug "disconnected from spacewalk server"
    end
  end
  
  def list_all_machines()
    @server.call('system.listUserSystems', @session)
  end
  
end