param! "login"
param! "email"
param! "password"

execute do |params|
  p = {}
  params.each do |k,v|
    p[k.to_sym] = v
  end
  u = User.new(p)
  u.save  
end
