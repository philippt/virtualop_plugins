description "sends an email"

param! "message", "the message body that should be sent (might include Subject header)"
param "to", "recipient address" 

execute do |params|
  puts "FOO42FOO"
  %w|smtp_host_name smtp_user smtp_port smtp_password|.each do |k| 
    params[k] = @plugin.config_string(k)
  end
  
  
  params['to'] ||= Thread.current['broker'].context.cookies['current_user_email']
  
  raise "need a recipient address" if params['to'] == nil or params['to'] == '' 
  
  result = false
  begin
    $logger.info "establishing SMTP connection to #{params["smtp_host_name"]}..."
    smtp = Net::SMTP.new params["smtp_host_name"], params["smtp_port"].to_i
    smtp.enable_starttls
    smtp.start('virtualop.org', params["smtp_user"], params["smtp_password"], :login) do |smtp|
      smtp.send_message params["message"], config_string('sender_address'), params['to']
    end       
    result = true
  rescue Exception => e
    $logger.error("could not send mail : #{e.message}")
  end
  
  result
end  