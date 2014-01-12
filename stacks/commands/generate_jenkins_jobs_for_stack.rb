param :machine, "the host onto which to deploy"
param :stack

accept_extra_params

add_columns [ :full_name, :status ]

on_machine do |machine, params|
  result = []
  
  @op.resolve_stack(params).each do |m|
    command_name = nil
    
    options = {}
    
    vm_name = m["name"]
    full_name = m["full_name"]
    
    option_string = ''
    m.each do |k,v|
      next if %w|vm_name full_name name|.include? k
      option_string += " #{k}=#{v}"
    end
    # TODO not a good idea (tm)
    # params["extra_params"].each do |k,v|
      # value = (v.is_a?(Array) && v.size == 1) ? v.first : v
      # option_string += " #{k}=#{value}"
    # end
    @op.create_jenkins_job("job_name" => full_name, "command_string" => "kaboom machine=#{full_name} #{option_string}")
    result << {
      "name" => vm_name,
      "full_name" => full_name,
      "status" => "ok"
    }
  end
  result
end