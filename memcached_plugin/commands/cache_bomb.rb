param "depth", "how many levels of cache should be invalidated", :default_value => 1

execute_request do |request, response|
  depth = request.get_param_value("depth")
  
  response.set_context('__caching.bomb' => depth)
  Thread.current['broker'].context.cookies['__caching.bomb'] = depth
end
