github_params
param! :github_project

add_columns [ :created_at, :actor_login, :message ]

execute do |params|
  JSON.parse(@op.http_get("url" => "https://api.github.com/repos/#{params["github_project"]}/events?access_token=#{params["github_token"]}")).map do |event|
    parse_event(event)
  end
end
