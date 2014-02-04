param! 'data', 'the parsed entries to aggregate (array of hashes)', :allows_multiple_values => true
param! 'log_type', '', :lookup_method => lambda { %w|access_log server_log| }
param 'interval', '', :lookup_method => lambda { %w|minute hour day week| }, :default_value => 'hour'

display_type :hash

execute do |params|
  raw = {}

  entries, log_type, interval = params['data'], params['log_type'], params['interval']
  
  entries.each do |entry|
    if entry
      corrected_timestamp = entry[:log_ts].to_i
      if %w|hour day week|.include? interval
        corrected_timestamp -= entry[:log_ts].sec
      end
      if %w|day week|.include? interval
        corrected_timestamp -= entry[:log_ts].min * 60
      end
      if %w|week|.include? interval
        corrected_timestamp -= entry[:log_ts].hour * 60 * 60
      end
    
      selector = if (log_type == 'access_log')
        (entry[:return_code].to_i < 400) ? :success : :failure
      elsif log_type == 'server_log'
        entry[:log_level]
      end
      raise "[woopsie] no selector found - that's probably a bug" unless selector
        
      raw[selector] = {} unless raw.has_key? selector
      hash = raw[selector]
      
      hash[corrected_timestamp] = [] unless hash.has_key? corrected_timestamp
      hash[corrected_timestamp] << entry
    else
      $logger.warn("nil entry")
    end
  end

  aggregated = {}

  raw.each do |selector, e|
    e.keys.sort.each do |bucket|
      aggregated[selector] = [] unless aggregated.has_key? selector
      aggregated[selector] << [
        bucket, e[bucket].size          
      ]
    end
  end

  out_count = 0
  raw[:success].keys.sort.each do |ts|
    bucket = raw[:success][ts]
    total = 0
    count = 0
    bucket.each do |entry|
    if entry[:response_time_microsecs]
      count += 1
      total += entry[:response_time_microsecs].to_i / 1000
    end
    end
    avg = total / count
    if out_count < 5
      puts "total for #{Time.at(ts)} : #{total}, count #{count} of #{bucket.size}. avg: #{avg}"
      out_count += 1
    end

    aggregated[:response_time_ms] ||= []
    aggregated[:response_time_ms] << [
      ts, avg
    ]
  end unless raw[:success] == nil

  aggregated
end
