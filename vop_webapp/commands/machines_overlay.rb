description "takes a list of machines, goes through all of them and executes a command on them, returning a hash with the output"

param :machine, "the machine thing", :allows_multiple_values => true
param! "overlay_command", "the command that should be executed on the machine"
param "overlay_column", "if the command returns a table, this parameter specifies which column(s) to display", :allows_multiple_values => true

#display_type :hash

mark_as_read_only

execute do |params|
  result = {}
  
  require 'timeout'
  
  params["machine"].each do |machine_name|
    @op.with_machine(machine_name) do |machine|
      begin
        $logger.info "getting overlay data from #{machine_name}..."
        # TODO we shouldn't use hard-coded timeouts like this, methinks        
        status = Timeout::timeout(result.size == 0 ? 60 : 5) {
          data = @op.send(params["overlay_command"].to_sym, {"machine" => machine_name})
          if params.has_key?("overlay_column")
            column_name = params["overlay_column"]
            $logger.info "picking out #{column_name}"
            data.map! { |x| x[column_name] }
          end 
          result[machine_name] = data
        }
      rescue => detail
        $logger.warn("couldn't get data for overlay '#{params["overlay_command"]}' from machine '#{machine_name}' : #{detail.message}")
      end
    end
  end
  result
end
