param :machine

param! "unix_service", "", :default_param => true

on_machine do |machine, params|
  result = params["unix_service"]
  if result.is_a?(Hash)
    distribution = machine.linux_distribution.split("_").first
                
    if result.has_key? distribution
      result = result[distribution]
    else
      raise "could not evaluate unix service name for distribution #{distribution}"
    end
  end
  result
end