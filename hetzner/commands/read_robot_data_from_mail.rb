description 'reads hetzner robot access data from an imap account'

params_as :list_mail

add_columns [ :login, :password ]

execute do |params|
  result = []
  mails = @op.list_mail(params.clone.merge({"threshold" => 0}))
  candidates = mails.select do |mail|
    mail["sender"] == "support@hetzner.de" and
    mail["subject"] == "Ihre Robot-Zugangsdaten"
  end
  candidates.each do |mail|
    p = params.clone
    p["uid"] = mail["uid"]
    
    $logger.info "checking mail #{mail["uid"]}"
    
    account = {}
    @op.read_mail(p).split("\n").each do |line|
      matched = /Login:\s*(.+)/.match(line)
      if matched
        account["login"] = matched.captures.first.strip
      else
        matched = /Password:\s*(.+)/.match(line)
        if matched
          account["password"] = matched.captures.first.strip
        end
      end
    end
    result << account    
  end
  
  result.each do |account|
    @op.add_hetzner_account(
      "alias" => account["login"],
      "user" => account["login"],
      "password" => account["password"]
    )
  end
  
  result
end
