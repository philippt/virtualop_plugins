param! 'data', 'the data lines that should be parsed', :allows_multiple_values => true

execute do |params|
  params['data'].map do |line|
    entry = nil
    
    line.strip! and line.chomp!

    # 2012-10-22 00:00:30,375 DEBUG [com.arjuna.ats.arjuna.logging.arjLogger] (Thread-12) Periodic recovery - first pass <Mo, 22 Okt 2012 00:00:30>
    # 2012-10-22 00:00:30,375 DEBUG [com.arjuna.ats.arjuna.logging.arjLogger] (Thread-12) StatusModule: first pass
    # 2012-10-22 00:00:30,375 DEBUG [com.arjuna.ats.txoj.logging.txojLoggerI18N] (Thread-12) [com.arjuna.ats.internal.txoj.recovery.TORecoveryModule_3] - TORecoveryModule - first pass
    
              #0 1 2 3 4
    pattern = /([\d\s:,-]+)\s+(\w+)\s+\[([\w\.]+)\]\s+(?:\(([^)]+)\)\s+)?(.+)/
    
    matched = pattern.match(line)
    if matched
      {
        #:log_ts => Time.at(DateTime.parse(matched.captures[0]).to_time.to_i - Time.zone.utc_offset).utc,
        :log_ts => Time.at(DateTime.parse(matched.captures[0]).to_time.to_i).utc,
        :log_level => matched.captures[1],
        :class_name => matched.captures[2],
        :message => matched.captures[4].strip.chomp,
        :stacktrace => ''
      }
    else
      nil
    end
  end
end    