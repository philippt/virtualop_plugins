def execute_on_spacewalk(&block)
  execute do |params|
    connection = @op.get_spacewalk_connection("spacewalk_host" => params['spacewalk_host'])
    block.call(connection.server, connection.session, params)
  end
end