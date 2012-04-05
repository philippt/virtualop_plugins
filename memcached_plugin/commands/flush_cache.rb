description "sets a cookie that will only accept responses newer than now (that sounds wrong, but it's late)"

execute_request do |request, response|    
  response.set_context('__caching.newer_than' => Time.now().to_i)
  Thread.current['broker'].context.cookies['__caching.newer_than'] = Time.now().to_i
end    