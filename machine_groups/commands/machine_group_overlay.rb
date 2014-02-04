description "overlays for machine groups"

param :machine_group, "the machine group to get data for", :allows_multiple_values => true
param! "overlay_command", "the command that should be executed"
param "overlay_column", "if the command returns a table, this parameter specifies which column(s) to display"

accept_extra_params

# TODO this doesn't seem to work for nil values in the hash
#display_type :hash

execute do |params|
  result = {}

    
  overlay_command = Thread.current['broker'].get_command(params["overlay_command"])
  
  params["machine_group"].each do |machine_group_name|
    begin
      $logger.info "getting overlay data from #{machine_group_name}..."
      
      if overlay_command.params.map { |p| p.name }.include? 'machine_group'
        result[machine_group_name] = @op.send(params["overlay_command"].to_sym, {"machine_group" => machine_group_name})
      else
        machines = @op.machines_in_group("machine_group" => machine_group_name).map { |x| x["name"] }
        result[machine_group_name] = []
        machines.each do |machine_name|
          begin
            #status = Timeout::timeout(result[machine_group_name].size == 0 ? 120 : 5) {
            status = Timeout::timeout(5) {
              options = {
                "machine" => machine_name
              }
              if params.has_key?("extra_params") and params["extra_params"] != ''
                params["extra_params"].each do |k,v|
                  options[k] = v
                end
              end
              data = @op.send(params["overlay_command"].to_sym, options)
              if data != nil
                $logger.info "#{machine_name} : #{data}"
                if data.class == Array
                  result[machine_group_name] += data
                else
                  result[machine_group_name] << data
                end
              end
            }  
          rescue => detail
            $logger.warn("couldn't get data for overlay '#{params["overlay_command"]}' from machine '#{machine_name}' : #{detail.message} at #{detail.backtrace.join("\n")}")
          end
        end
      end
    rescue => detail
      $logger.warn("couldn't get data for overlay '#{params["overlay_command"]}' from machine group '#{machine_group_name}' : #{detail.message}")
    end
  end
  
  if params.has_key?("overlay_column")
    column_name = params["overlay_column"]
    result.each do |k,v|
      v.map! { |x| x[column_name] }
    end
  end
  
  result
end