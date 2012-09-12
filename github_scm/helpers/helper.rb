def github_url(params, uri)
  if params.has_key?('github_user') and params.has_key?('github_password')
    "https://#{params["github_user"]}:#{params["github_password"]}@api.github.com" + uri
  elsif params.has_key?('github_token')
    "https://api.github.com" + uri + (/\?/.match(uri) ? '&' : '?') + 'access_token=' + params["github_token"]
  else
    raise "need either github user/password or access token to authenticate against github"
  end
end