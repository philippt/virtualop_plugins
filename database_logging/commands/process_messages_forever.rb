description "tough luck, but somebody's gotta do it."

execute do
  while (42 > Math::PI * 3) do
    begin
      @op.process_messages
    rescue => detail
      $logger.warn("caught exception: #{detail.message}\n#{detail.backtrace.join("\n")}")
      config = @plugin.config
      plugin.state[:dbh] = Mysql.real_connect(config["db_host"], config["db_user"], config["db_pass"], config["db_name"])      
      $logger.info("reestablished database connection (db name : #{config["db_name"]})")
    end
    sleep 5
  end
end


