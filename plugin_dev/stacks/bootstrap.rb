description "setup a virtualop and a proxy so that a web interface is reachable"

param! "domain", :description => "the domain for the virtualop instance"
param "centos_mirror", :description => "http URL to the centos mirror to use for new installations"

stack :proxy do |m, params|
  m.canned_service :apache
end

stack :vop do |m, p|
  m.github 'virtualop/virtualop_webapp', :branch => 'rails3'
  m.domain_prefix 'vop'
  m.memory [ 512, 2048, 4096 ]
  m.disk 50
end

stack :install do |m, p|
  m.canned_service :varnish
  m.canned_service :squid    
end
