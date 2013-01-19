description 'reads the body of an email'

param! "imap_host", "an imap host name to connect to"
param! "imap_port", "the port number to connect to"
param! "imap_user", "the user name to connect with"
param! "imap_password", "the password to use for the connection"
param "threshold", "the maximal amount of messages to fetch (defaults to 20)"
param "new_messages_only", "if 'true', will show only unread messages (default: false)", 
  :lookup_method => lambda {
    %w|true false|  
  }
#params_as :list_mail

param "uid", "the uid of the mail that should be read", :mandatory => true

execute do |params|
  imap = Net::IMAP.new(params["imap_host"], params["imap_port"], true)
  imap.login(params["imap_user"], params["imap_password"])
  imap.select('INBOX')
  imap.fetch(params["uid"].to_i,"BODY[TEXT]")[0].attr["BODY[TEXT]"]
end
