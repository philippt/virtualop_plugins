execute do |params|
  @op.listen_to_rabbit("queue" => "raw_logging")
end
