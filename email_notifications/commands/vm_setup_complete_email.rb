params_as :notify_vm_setup_complete

contributes_to :notify_vm_setup_complete

on_machine do |machine, params|
  puts "+++ vm_setup_complete_email +++"
  request = Thread.current['request']
  pp request
  
  context = Thread.current['broker'].context
  pp context
  params['to'] = context.cookies['current_user_email']
  
  message = read_local_template(:vm_setup_complete, binding())
  p message
    
  @op.send_mail("message" => message, "to" => params['to'])
    
  []
end
