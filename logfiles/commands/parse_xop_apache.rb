param! 'data', 'the data lines that should be parsed', :allows_multiple_values => true

display_type :list

execute do |params|
  params['data'].map do |line|
    entry = nil
    
    line.strip! and line.chomp!
  
    #        amf.beta.bettermarks.com 1254923618 10.10.10.2 10.4.97.50, 217.86.148.67 200 202b 832ms - "GET /crossdomain.xml HTTP/1.0" "-" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; WOW64; Trident/4.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; FDM; .NET CLR 3.5.30729; .NET CLR 3.0.30729; OfficeLiveConnector.1.4; OfficeLivePatch.1.3)"
    #             host    epoch   remote_ip   x_forwarded_for             status  bytes   microsecs      auth?   method  url                 version  ref      user agent
    #result = /^\s*(\S+)\s+(\d+)\s+([\d\.]+)\s+((?:[\d\.\w]+,\s)*[\d+\.\w]+)\s+(\d+)\s+(.+)b\s+(\d+)ms\s+(\S+)\s+"(\w+)\s+(\S+?)(?:\?(.+))?\s+(.+)"\s+"(.+)"\s+"(.+)"$/.match(line)
    #
    #         '1259441327 [28/Nov/2009:21:48:47 +0100] amf.staging.bettermarks.com 10.51.10.2 78.53.11.124 200 2117b 29000micros - "POST /exercise/ HTTP/1.1" "http://static.staging.bettermarks.com/bm_miniExercisePreview.swf" "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.15) Gecko/2009102815 Ubuntu/9.04 (jaunty) Firefox/3.0.15"'
    #          epoch                host    remote ip   x_forwarded_for                status  bytes   microsecs     auth?   method    url                version  ref      useragent
    #result = /^([\d\.]+)\s+\[.+\]\s+(\S+)\s+(.+)\s+((?:[\d\.\w]+,\s)*[\d+\.\w]+)\s+(\d+)\s+(.+)b\s+(\d+)micros\s+(\S+)\s+"(\w+)\s+(\S+?)(?:\?(.+))?\s+(.+)"\s+"(.+)"\s+"(.+)"$/.match(line)
    #result = /^([\d\.]+)\s+\[.+\]\s+(\S+)\s+(.+)\s+((?:[\d\.\w]+,\s)*[\d+\.\w]+)\s+(\d+)\s+(.+)b\s+(\d+)micros\s+(\S+)\s+"(\w+)\s+(\S+?)(?:\?(.+))?"\s+"([^"]+)"\s+"([^"]+)"$/.match(line)
    result = /^([\d\.]+)\s+\[.+\]\s+(\S+)\s+(.+)\s+((?:[\d\.\w]+,\s)*[\d+\.\w]+)\s+(\d+)\s+(.+)b\s+(\d+)micros\s+(\S+)\s+"(\w+)\s+(\S+?)(?:\?(.+))?(?:\s+(.+))?"\s+"([^"]+)"\s+"([^"]+)"$/.match(line)
    if result then
      entry = {
        :log_ts => Time.at(result.captures[0].to_i),
        :http_host_name => result.captures[1],
      
        :remote_ip => result.captures[2],
        :x_forwarded_for => result.captures[3],
  
        :return_code => result.captures[4],
        :response_size_bytes => result.captures[5],
        :response_time_microsecs => result.captures[6],
        :http_method => result.captures[8],
        :method_name => result.captures[9],
        :query_string => result.captures[10],
        :http_version => result.captures[11],
        :referrer => result.captures[12],
        :user_agent => result.captures[13]
      
      }
    end

    # postprocess what we got
    if entry
      # entry[:host_name] = @host_name
      # entry[:service_name] = @service_name

      # for the source ip - if x-forwarded-for is set, it's the last part of
      # x-forwarded-for that is not "unknown", otherwise it's the remote_ip
      if (entry[:x_forwarded_for]) then
        parts = entry[:x_forwarded_for].split(", ")
        # TODO take the first part of the x_forwarded_for header
        parts.reverse.each do |part|
          if part != "unknown" && part != "unknownn" # this wasn't me...
            entry[:source_ip] = part
            break
          end
        end
      else
        entry[:source_ip] = entry[:remote_ip]
      end

      entry[:md5_checksum] = 42
#      entry.md5_checksum = Digest::MD5.hexdigest(
#        entry.log_ts.to_s +
#        entry.remote_ip + entry.x_forwarded_for +
#        entry.method_name +
#        entry.host_name + entry.service_name +
#        entry.response_size_bytes.to_s + entry.response_time_microsecs.to_s
#      )
    end

    entry
  end
end
