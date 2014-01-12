description "returns a graph with number of commits per day for a user"

github_params

param! "user_name", "github username of the user for which events should be displayed", :allows_multiple_values => true

execute do |params|
  by_day = {}
  @op.graph_events_for_user(params).each do |event|
    timestamp = event.first / 1000
    the_day = Time.at(timestamp).strftime("%Y%m%d")
    if by_day.has_key? the_day
      by_day[the_day] += 1
    else
      by_day[the_day] = 1
    end
  end
  
  result = []
  
  ONE_DAY = 60 * 60 * 24
  0.upto(7) do |i|
    day = Time.at(Time.now().to_i - (i * ONE_DAY))
    day_string = day.strftime("%Y%m%d")
    epoch = day.to_i * 1000
    if by_day.has_key? day_string
      result << [ epoch, by_day[day_string] ]
    else
      result << [ epoch, 0 ]
    end
  end
  
  result
end
