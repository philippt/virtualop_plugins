description "performs a DNS request for the specified name or ip address (wrapper for 'dig')"

param :machine, "the machine to execute 'dig' on", :mandatory => false, :default_value => 'localhost'
param! "query", "the thing to query for - can be either an IP address or an hostname", :is_default_param => true
param "name_server", "the nameserver that should be queried"

mark_as_read_only

add_columns [ "direction", "hostname", "ip" ]

on_machine do |machine, params|
  result = []

  is_ip_address = /^(\d+\.\d+\.\d+\.\d+)$/.match(params["query"])

  command = "dig"
  command += " -x" if is_ip_address
  command += " " + params["query"]
  
  if params.has_key?('name_server')
    command += " @" + params['name_server']
  end

  output = machine.ssh("command" => command)

  found_the_answer = false

  # ;; ANSWER SECTION:
  # complete01.nevis.lab.bm.loc. 172800 IN  A       10.31.30.10
  # bind.curacao.dev.bm.loc. 172800 IN      A       10.41.10.3
  # 10.30.31.10.in-addr.arpa. 172800 IN     PTR     complete01.nevis.lab.bm.loc.
  
  #
  # forward lookup with CNAME
  # ;; ANSWER SECTION:
  # spacewalk.bm.loc.       172800  IN      CNAME   spacewalk.barbados.inf.bm.loc.
  # spacewalk.barbados.inf.bm.loc. 172800 IN A      10.10.10.6
  output.split("\n").each do |line|
    line.strip!
    if found_the_answer
      break if /;;/.match(line)
      next if /^$/.match(line)

      regex = is_ip_address ?
        /((\d+\.\d+\.\d+\.\d+)\.\S+)\.\s+\d+\s+(\w+)\s+(\w+)\s+(\S+)\.$/ :
        /(\S+)\.\s+\d+\s+(\w+)\s+(\w+)\s+(\d+\.\d+\.\d+\.\d+)$/

      $logger.debug "checking #{line}"

      matched = regex.match(line)
      if matched

        if is_ip_address
          correct_ip = matched.captures[1].split(".").reverse.join(".")
          answer = {
            "direction" => "reverse",
            "hostname" => matched.captures[4],
            "ip" => correct_ip
          }
        else
          answer = {
            "direction" => "forward",
            "hostname" => matched.captures[0],
            "ip" => matched.captures[3]
          }
        end

        result << answer
      else
        # TODO reactive error-handling
        #$logger.error("couldn't parse dig's output...something is wrong here!")
      end
    else
      found_the_answer = /;; ANSWER SECTION:/.match(line)
    end
  end

  result
  
end
