description "sends a test mail"

param! "to", "the recipient address", :is_default_param => true

execute do |params|
  puts "FOO40"
  message = read_local_template(:test, binding())
    
  puts "FOO41"
  @op.send_mail("message" => message, "to" => params['to'])
    
  []
end
