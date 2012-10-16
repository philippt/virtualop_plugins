param :dropbox_token

execute do |params|
  with_dropbox(params) do |client|
    cursor = nil
    
    while (true) do
      result = client.delta(cursor)
      puts "found #{result["entries"].size} delta entries"
      pp result["entries"]
      
      cursor = result["cursor"]
      
      sleep_time = result["has_more"] ? 0 : 15
      sleep sleep_time
    end    
  end
end