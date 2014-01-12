param! 'data', 'aggregated entries (hash)'
param! 'log_type', '', :lookup_method => lambda { %w|access_log server_log| }
param 'interval', '', :lookup_method => lambda { %w|minute hour day week| }, :default_value => 'hour'
param 'count', 'amount of intervals to display', :default_value => 1

execute do |params|
  now = Time.now
  count = params['count'].to_i
  
  buckets = params['data']
  case params['interval'].to_sym
  when :minute
    start = now.to_i
    buckets.each do |selector, line|
      new_data = []

      0.upto(59 * count) do |offset|
        ts = start - offset
        new_data << point_or_null(line, ts)
      end

      buckets[selector] = new_data
    end        
        
  when :hour
    start = now.to_i - now.sec

    buckets.each do |selector, line|
      new_data = []
      0.upto(59 * count) do |offset|
        ts = start - offset * 60
        new_data << point_or_null(line, ts)
      end
      buckets[selector] = new_data
    end

  when :day
    start = now.to_i - now.sec - now.min * 60

    buckets.each do |selector, line|
      new_data = []
      0.upto(23 * count) do |offset|
        ts = start - offset * 60 * 60
        new_data << point_or_null(line, ts)
      end
      buckets[selector] = new_data
    end
      
  when :week
    start = now.to_i - now.sec - now.min * 60 - now.hour * 60 * 60

    buckets.each do |selector, line|
      new_data = []
      
      0.upto(6 * count)  do |offset|
        ts = start - offset * 60 * 60 * 24
        new_data << point_or_null(line, ts)
      end

      buckets[selector] = new_data
    end
  else
    # TODO no interval?
    raise "unknown interval : #{params['interval']}"
  end

  buckets.each do |selector, e|
    e.each do |entry|
      entry[0] = entry[0] * 1000
    end
  end
  
  buckets
  
end