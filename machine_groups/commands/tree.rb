description "returns a tree of machine groups and machines"

param "path", "a path fragment to use as filter", :default_param => true
param "json", "if set to true, returns the output as JSON", :default_value => false

execute do |params|
  groups = @op.list_machine_groups.sort_by { |x| x["path"] }
  # if params.has_key?("path")
    # groups.delete_if { |group|
      # (/#{params["path"]}/ !~ group["path"]) #&&
      # #(/^#{group["path"]}/ !~ params["path"])
    # }
  # end
  #pp groups
  #puts "\n" * 5
  
  groups = groups.map { |x|
    {
      "node" => x,
      "children" => []
    }
  }
  
  
  # if params.has_key?("path")    
    # path_parents = []
    # parts = params["path"].split('/')
    # pp parts
    # 0.upto(parts.size-1) do |loop|
      # path_parents << parts[0..loop].join('/')
    # end
    # puts "path_parents : #{path_parents.map { |x| ">>#{x}<<"}.join(" ")}"
#     
    # groups.delete_if { |x| 
      # /#{params["path"]}/ !~ x["node"]["path"] && 
      # x["node"]["path"] != '/' &&
      # ! path_parents.include?(x["node"]["path"])
    # }
  # end

  puts 'yehova!'
  pp groups.first["node"]["path"]
  while (groups.size > 0 && groups.first["node"]["path"].split('/').size > 0)
    child = groups.shift

    parts = child["node"]["path"].split('/')
    parent_path = parts[0..-2].join('/')
    if parent_path == ''
      parent_path = '/'
    end
    
    parent = groups.find{ |x|
      x["node"]["path"] == parent_path
    }
    
    if parent
      parent["children"] << child 
    # else
      # raise "no parent found. the little #{child["node"]["path"]} wants to be picked up by it's parent #{parent_path}"
      puts "#{child["node"]["path"]} -> #{parent["node"]["path"]}"
    end
  end
  
  pp groups.map { |x| x["node"]["path"] }
#   
  # if params.has_key?("path")
    # parts = params["path"].split('/')
    # pointer = groups.first
    # parts.each do |part|
      # next if part == '' 
      # #if pointer["children"]
    # end
#     
    # delete = lambda { |nodes| 
      # nodes.delete_if { |node|
        # path = node["node"]["path"]
        # result = 
          # (/#{params["path"]}/ !~ path) && 
          # (/^#{path}/ !~ params["path"]) &&
          # ! (path == '/')        
        # puts "deleting #{node["node"]["path"]}" if result
        # result
      # }   
      # nodes.each do |node|
        # delete.call(node["children"])
      # end
    # }
    # delete.call(groups)    
  # end
    
  if params["json"].to_s == 'true'
    groups.to_json()
  else
    groups
  end
end
