param! "domain", :description => "the domain for the web application"

stack :foo do |m, params|
  m.github 'philippt/virtualop_website'
  m.domain params["domain"]
  m.param("vop_url", "http://vop.dev.virtualop.org")
end

on_install do |stacked, params|
  @op.comment("message" => (%w|+++ foo|*(42/2)).join(' '))
end  

post_rollout do |stacked, params|
  pp params
  @op.comment "foo has been rolled out. successful: #{params["result"][:success].size}, failed: #{params["result"][:failure].size}" 
end

