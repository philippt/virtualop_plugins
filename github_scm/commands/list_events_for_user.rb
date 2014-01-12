github_params

param! "user_name", "github username of the user for which events should be displayed"

add_columns [ :created_at, :user, :message ]

mark_as_read_only # TODO expires 15.minutes

execute do |params|
  JSON.parse(@op.http_get("url" => "https://api.github.com/users/#{params["user_name"]}/events?access_token=#{params["github_token"]}")).map do |event|
    parse_event(event)
  end
end
