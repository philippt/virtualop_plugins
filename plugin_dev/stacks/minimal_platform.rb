description "minimal set of infrastructure for running a web platform"

param! "domain", :description => "the domain root for the web applications"

stack :vop do |m, p|
  m.github 'virtualop/virtualop_webapp', :branch => 'rails3'
  m.domain_prefix 'vop'
  m.memory [ 512, 1024, 2048 ]
  m.disk 50
end

stack :nagios do |m, p|
  m.canned_service :nagios
  m.domain_prefix 'nagios' 
  m.memory [ 512, 1024, 1024 ]
  m.disk 50
end
 
stack :xoplogs do |m, params|
  m.github 'philippt/xoplogs'
  m.domain_prefix 'xoplogs'
  m.memory [ 512, 1024, 2048 ]
  m.disk 100
end
 
stack :datarepo do |m, params|
  m.canned_service :datarepo
  m.domain_prefix 'datarepo'
  m.disk 100
end
 
stack :powerdns do |m, params|
  m.canned_service :powerdns
end
 
stack :proxy do |m, params|
  m.canned_service :apache
end
 
stack :vop_website do |m, params|
  m.github 'philippt/virtualop_website'
  m.domain params["domain"].first
end
 
