description "dummy authenticate method (no ldap here)"

param "uid", "", :mandatory => true
param "password", "", :mandatory => true

execute do |params|
  params['uid'] == config_string('user') and params['password'] == config_string('password')
end
