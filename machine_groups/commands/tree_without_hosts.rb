execute do |params|
  @op.tree do |x|
    x.has_key?("type") and x["type"] == 'host'
  end
end