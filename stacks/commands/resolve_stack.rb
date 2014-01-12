param :stack
param "blacklist", "name of a machine that should be ignored", :allows_multiple_values => true
param "whitelist", "name of a machine that should be included", :allows_multiple_values => true

param :machine, "a host onto which to deploy"
param "prefix", "prefix for the VM names"

accept_extra_params

add_columns [ :full_name, :domain ]

execute do |params|
  result = []
  
  stacks = @op.list_stacks.select { |x| params["stack"].include? x["name"] }
  
  machines = []
  stacks.each do |stack|
    machines += stack["machines"]
  end
  
  host_name = params["machine"]
  
  machines.each do |machine_def|
    
    next if params.has_key?("blacklist") and params["blacklist"].include? machine_def.name
    next if params.has_key?("whitelist") and not params["whitelist"].include? machine_def.name
    
    begin
      (params["extra_params"] || {}).each do |k,v|
        v = v.first if v.is_a? Array
        params[k] = v
      end
      machine_def.params = params
      param_string = ""
      machine_def.params.each do |k,v|
        param_string += "\t#{k}\t#{v}\n"
      end
      
      $logger.info "resolving machine definition #{machine_def.name}:\n#{param_string}"
      machine_def.block.call(machine_def, params)
      
      prefix = params.has_key?("prefix") ? params["prefix"] : ''
      vm_name = prefix + machine_def.name
      
      h = {
        "name" => machine_def.name,
        "vm_name" => vm_name,
        "full_name" => vm_name + '.' + host_name,
      }
      h.merge! machine_def.data 
      
      result << h
    rescue => detail
      $logger.warn("could not parse machine definition #{machine_def.name} for stack #{params["stack"]} : #{detail.message}, #{detail.backtrace.join("\n")}")
    end
    
  end
  
  result
end
