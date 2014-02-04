param! 'data', 'the data lines that should be parsed', :allows_multiple_values => true

execute do |params|
  params['data'].map do |line|
    entry = nil
    
    line.strip! and line.chomp!

    # this works with a log4j config like
    # <param name="ConversionPattern" value="%d [%t] %-5p %c - %m%n" />
    # or (for timezoned timestamps)
    # <param name="ConversionPattern" value="%d{yyyy.M.d H:m:ss Z} [%t] %-5p %c - %m%n" />
    #
    # 2013-11-05 15:53:54,252 [main] INFO org.apache.catalina.startup.Catalina - Server startup in 126 ms
    # 2013.11.10 16:27:03 +0100 [main] INFO org.apache.catalina.startup.Catalina - Server startup in 173 ms
    
              #0 1 2 3
    pattern = /([\d\s:,+-]+)\s+\[(\S+)\]\s+(\S+)\s+(.+?)\s+-\s+(.+)$/
    
    matched = pattern.match(line)
    if matched
      begin
        {
          :log_ts => DateTime.parse(matched.captures[0]).to_time,
          :host_name => @host_name,
          :service_name => @service_name,
          :log_level => matched.captures[2],
          :class_name => matched.captures[3],
          :message => matched.captures[4].strip.chomp,
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