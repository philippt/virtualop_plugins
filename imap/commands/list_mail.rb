description "connects to an imap server and examines a single folder"

param! "imap_host", "an imap host name to connect to"
param! "imap_port", "the port number to connect to"
param! "imap_user", "the user name to connect with"
param! "imap_password", "the password to use for the connection"
param "threshold", "the maximal amount of messages to fetch (defaults to 20)"
param "new_messages_only", "if 'true', will show only unread messages (default: false)", 
  :lookup_method => lambda {
    %w|true false|  
  }
  
add_columns [ :date, :sender, :subject, :flags ]

mark_as_read_only

execute do |params|
  result = []
    
  threshold = params.has_key?("threshold") ? params["threshold"].to_i : 20
  
  imap = Net::IMAP.new(params["imap_host"], params["imap_port"], true)
  imap.login(params["imap_user"], params["imap_password"])
  begin
    imap.select('INBOX')
    #imap.examine('INBOX')
    search_flags = [ "NOT", "DELETED" ]
    if params.has_key?("new_messages_only") and params["new_messages_only"] == "true"
      search_flags += [ "NOT", "SEEN" ]
    end
    uids = imap.uid_search(search_flags)
    @op.comment("message" => "found #{uids.size} messages")
    idx = 0
    uids.sort.reverse.each do |uid|
      idx += 1
      break if idx > threshold and threshold != 0
      msg = imap.uid_fetch(uid, ['ENVELOPE', 'FLAGS']).first
      #source = msg.first.attr['RFC822']      
      envelope = msg.attr['ENVELOPE']
      
      #p msg.attr
      
      #p msg.attr['FLAGS']
      
      if params.has_key?('block')
        params['block'].call(uid, msg, envelope)
      end
      
      result << {
        "uid" => uid,
        "date" => Time.parse(envelope.date),
        "sender" => "#{envelope.sender.first.mailbox}@#{envelope.sender.first.host}",
        "subject" => envelope.subject,
        "flags" => msg.attr['FLAGS'].join(",")
      }
      
      $logger.info "." if idx % 10 == 0
    end
  ensure
    # TODO logout
  end
  
  result
end    
