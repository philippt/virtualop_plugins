def access_log_graph_flot(data, tz_offset)
  data.each do |name, line|
    line.each do |a|
      timestamp, value = a.first, a.last
      old_ts = timestamp.to_i
      new_ts = ((old_ts / 1000) + tz_offset) * 1000
      #puts "#{old_ts.to_s} -> #{new_ts.to_s}"
      a[0] = new_ts
    end
    
    color, title = nil
    yaxis = 1
    
    case name
    when "count_success", "success"
      title = "success"
      color = 0
    when "count_errors", "failure"
      title = "error"
      color = 2
    when "response_time_ms"
      title = "duration (ms)"
      color = 1
      yaxis = {
        :position => "right" 
      }
      stack = 'none'
    else
      title = name
    end
    
    data[name] = {
      :data => line,
      :label => title,
      :color => color,
      :yaxis => yaxis
    } 
  end
  data
end    