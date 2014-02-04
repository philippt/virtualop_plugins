description "takes a list of machines, goes through all of them and executes a command on them, returning a hash with the output"

param :machine, "the machine thing", :allows_multiple_values => true, :allows_extra_values => true
param! "overlay_command", "the command that should be executed on the machine"
param "overlay_column", "if the command returns a table, this parameter specifies which column(s) to display", :allows_multiple_values => true

accept_extra_params

#display_type :hash

# TODO how do we invalidate data in cached overlays?
#mark_as_read_only

execute do |params|
  result = {}
  
  require 'timeout'
  
  results = params["machine"].map do |machine_name|
    h = {}
    begin
      @op.with_machine(machine_name) do |machine|
        if machine.reachable_through_ssh
          $logger.info "getting overlay data from #{machine_name}..."
          
          options = {
            "machine" => machine_name
          }
          if params.has_key?("extra_params") and params["extra_params"] != ''
            params["extra_params"].each do |k,v|
              options[k] = v
            end
          end
          
          # TODO we shouldn't use hard-coded timeouts like this, methinks        
          status = Timeout::timeout(result.size == 0 ? 60 : 5) {
            data = @op.send(params["overlay_command"].to_sym, options)
            if params.has_key?("overlay_column")
              column_name = params["overlay_column"]
              $logger.info "picking out #{column_name}"
              data.map! { |x| x[column_name] }
            end 
            h[machine_name] = data
          }
        else
          h[machine_name] = []
        end
      end
    rescue => detail
      $logger.warn("couldn't get data for overlay '#{params["overlay_command"]}' from machine '#{machine_name}' : #{detail.message}")
    end
    h
  end
  
  results.each do |r|
    result.merge! r
  end

  result
end
