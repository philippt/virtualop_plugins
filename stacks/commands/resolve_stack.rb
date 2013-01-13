#param! "stack", "the stack that should be evaluated", 
#  :lookup_method => lambda { @op.list_stacks.map { |x| x["name"] } }, :allows_multiple_values => true
param :stack
param "blacklist", "name of a machine that should be ignored", :allows_multiple_values => true

accept_extra_params

execute do |params|
  result = []
  stacks = @op.list_stacks.select { |x| params["stack"].include? x["name"] }
  machines = []
  stacks.each do |stack|
    machines += stack["machines"]
  end 
  machines.each do |machine_def|
    next if params.has_key?("blacklist") and params["blacklist"].include? machine_def.name
    begin
      (params["extra_params"] || []).each do |k,v|
        if v.class == Array.class
          v = v.first
        end 
        params[k] = v
      end
      machine_def.params = params
      param_string = ""
      machine_def.params.each do |k,v|
        param_string += "\t#{k}\t#{v}\n"
      end
      $logger.info "resolving machine definition #{machine_def.name}:\n#{param_string}"
      machine_def.block.call(machine_def, params)
      result << machine_def
    rescue => detail
      $logger.warn("could not parse machine definition #{machine_def.name} for stack #{params["stack"]} : #{detail.message}, #{detail.backtrace.join("\n")}")
    end
  end
  pp result    
  result
end
