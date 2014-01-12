def github_url(params, uri)
  if params.has_key?('github_user') and params.has_key?('github_password')
    "https://#{params["github_user"]}:#{params["github_password"]}@api.github.com" + uri
  elsif params.has_key?('github_token')
    "https://api.github.com" + uri + (/\?/.match(uri) ? '&' : '?') + 'access_token=' + params["github_token"]
  else
    raise "need either github user/password or access token to authenticate against github"
  end
end

def parse_event(event)
  event["user"] = event["actor"]["login"] if event.has_key?("actor") and event["actor"].has_key?("login")
    
  event["message"] = event["payload"]["commits"].first["message"] if event.has_key?("payload") and event["payload"].has_key?("commits") and
    event["payload"]["commits"].size > 0 and event["payload"]["commits"].first.has_key?("message")
    
  if event.has_key?("type") and event["type"] == "CreateEvent" and event.has_key?("payload") and event["payload"].has_key?("ref")
    event["message"] = "created tag #{event["payload"]["ref"]}"      
  end
  
  event["timestamp"] = DateTime.parse(event["created_at"])
  
  event
end
