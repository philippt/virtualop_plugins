execute do |params|
  @plugin.brokers.first.flush_buffer(@op)
end
