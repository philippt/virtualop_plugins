description "executes a block with disabled cache read (useful for invalidating or refreshing the cache)"

param "block", "the block that should be executed without reading from the cache", :mandatory => true

execute do |params|
  @op.flush_cache
  params["block"].call(params)
end
