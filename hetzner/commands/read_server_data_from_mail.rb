description 'reads hetzner server access data from an imap account'

params_as :list_mail

add_columns [ :ip_address, :login, :password, :updated ]

execute do |params|
  result = []
  mails = @op.list_mail(params)
  candidates = mails.select do |mail|
    mail["sender"] == "support@hetzner.de" and
    /Ihr bestellter(.+)Server/.match(mail["subject"]) 
  end
  candidates.each do |mail|
    p = params.clone
    p["uid"] = mail["uid"]
    
    server = {
      "mail_uid" => mail["uid"],
      "updated" => false 
    }
    ip_address_found = false
    @op.read_mail(p).split("\n").each do |line|
      line.strip!
      matched = /IP-Address: ([\d\.]+)/.match(line)
      if matched then
        ip_address_found = true  
        server["ip_address"] = matched.captures.first
      else
        matched = /Login:\s*(.+)/.match(line)
        if matched
          server["login"] = matched.captures.first
        else
          matched = /Password:\s*(.+)/.match(line)
          if matched
            server["password"] = matched.captures.first
            break
          end
        end
      end
    end
    result << server    
  end
  
  result.each do |server|
    candidates = @op.list_known_machines().select do |candidate|
      candidate["ssh_host"] == server["ip_address"] and
      candidate["ssh_port"] == "22" and
      candidate["type"] == "host"
      #candidate["ssh_password"] == ""
    end
    if candidates.size != 1
      $logger.warn("could not identify which machine to update for ip address #{server["ip_address"]} (mail uid #{server["mail_uid"]}) - found these candidates: \n#{candidates.to_json()}")
      next
    end
           
    @op.update_ssh_options(
      "machine" => candidates.first["name"],
      "ssh_user" => server["login"],
      "ssh_pass" => server["password"]      
    )
    server["updated"] = true
  end
  
  result
end
