param! 'data', 'the data lines that should be parsed', :allows_multiple_values => true
param 'tz_offset', 'tz offset in hours from UTC that is applied to timestamps read from the logfile', :default_value => 0

execute do |params|
  params['data'].map do |line|
    entry = nil
    
    line.strip! and line.chomp!
              #I, [2013-11-12T18:01:34.770319 #10815]  INFO -- : [ssh stop] result code : 127, output: 28 bytes
              #.          .                  .         .             .                    
    pattern = /(\w+),\s+\[([\d\s:,\.+-T]+)\s#(\d+)\]\s+(\w+)\s+--\s+:(.+)/
    
    matched = pattern.match(line)
    if matched
      begin
        ts_epoch = DateTime.parse(matched.captures[1]).to_time.to_i
        offset_secs = params['tz_offset'].to_i# * 3600
        {
          :log_ts => Time.at(ts_epoch - offset_secs).utc,
          :log_level => matched.captures[3],
          :class_name => '',
          :thread => matched.captures[2],
          :message => matched.captures[4] ? matched.captures[4].strip.chomp : '',
          :stacktrace => ''
        }
      rescue => detail
        $logger.warn("could not parse line #{line} : #{detail.message}")
        nil
      end
    else
      nil
    end
  end
end    