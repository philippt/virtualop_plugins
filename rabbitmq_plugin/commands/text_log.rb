display_type :list

execute do |params|
  @op.listen_to_rabbit("queue" => "text_logging")
end
