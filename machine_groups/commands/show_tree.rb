param "path", "a path fragment to use as filter", :default_param => true

display_type :hidden

execute do |params|  
  root = @op.tree(params).first
  
  recurse = lambda { |node, level = 0|
    puts "#{" " * level}#{node["node"]["path"]}"
    node["children"].each do |child|
      recurse.call(child, level + 1)
    end
  }
  
  recurse.call(root)
end
