description "returns a tree of machine groups and machines"

param "path", "a path fragment to use as filter", :default_param => true
param "json", "if set to true, returns the output as JSON", :default_value => false
param "block", "a block that is used in conjunction with delete_if to filter out machine from the list before building the tree"

execute do |params|
  groups = @op.list_machine_groups.sort_by { |x| x["path"] }.reverse

  if params.has_key?("block")
    groups.delete_if do |x|
      params["block"].call(x)
    end
  end
  
  groups = groups.map { |x|
    {
      "node" => x,
      "children" => []
    }
  }
  
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
      puts "#{child["node"]["path"]} -> #{parent["node"]["path"]}"
    end
  end
  
  if params["json"].to_s == 'true'
    groups.to_json()
  else
    groups
  end
end
