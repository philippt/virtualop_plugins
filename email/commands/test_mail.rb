description "sends a test mail"

param "to", "the recipient address", :is_default_param => true

on_machine do |machine, params|
  puts "FOO40"
  message = read_local_template(:test, binding())
    
  puts "FOO41"
  @op.send_mail("message" => message, "to" => params['to'])
    
  []
end
