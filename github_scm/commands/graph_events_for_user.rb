github_params

param! "user_name", "github username of the user for which events should be displayed", :allows_multiple_values => true

execute do |params|
  lines = []
  
  params["user_name"].each do |user_name|
    #data = []
    p = params.clone
    p["user_name"] = user_name
    @op.list_events_for_user(p).each do |event|
      lines << [
          Time.parse(event["created_at"]).to_i * 1000,
          1
        ]
    end
    #lines << data.clone
  end
  
  

  # {
    # :data => lines,
    # :label => "github events",
    # :lines => {
      # :show => true,
    # },
    # :points => {
      # :show => true
    # }
  # }
  lines
end
