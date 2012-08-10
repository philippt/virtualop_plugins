description "executes a block with disabled cache read (useful for invalidating or refreshing the cache)"

param "block", "the block that should be executed without reading from the cache", :mandatory => true

execute do |params|
  cookies = Thread.current['broker'].context.cookies
  key = '__caching.newer_than'
  old_threshold = cookies[key] if cookies.has_key? key
   
  cookies[key] = Time.now().to_i
  
  result = params["block"].call(params)
  
  if old_threshold != nil
    cookies[key] = old_threshold
  else
    cookies.delete key  
  end
  result
end
