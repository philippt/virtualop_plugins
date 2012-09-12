description "overlays for machine groups"

param :machine_group, "the machine group to get data for", :allows_multiple_values => true
param! "overlay_command", "the command that should be executed"
param "overlay_column", "if the command returns a table, this parameter specifies which column(s) to display"

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
              data = @op.send(params["overlay_command"].to_sym, {"machine" => machine_name})
              if data != nil
                $logger.info "#{machine_group_name} : #{data}"
                result[machine_group_name] += data
              end
            }  
          rescue => detail
            $logger.warn("couldn't get data for overlay '#{params["overlay_command"]}' from machine '#{machine_name}' : #{detail.message}")
          end
        end
      end
    rescue => detail
      $logger.warn("couldn't get data for overlay '#{params["overlay_command"]}' from machine group '#{machine_group_name}' : #{detail.message}")
    end
  end
  
  if params.has_key?("overlay_column")
    column_name = params["overlay_column"]
    $logger.info "picking out #{column_name}"
    result.each do |k,v|
      v.map! { |x| x[column_name] }
    end
  end
  
  result
end