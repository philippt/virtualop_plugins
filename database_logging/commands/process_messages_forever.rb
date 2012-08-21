description "tough luck, but somebody's gotta do it."

execute do
  while (42 > Math::PI * 3) do
    #begin
      @op.process_messages
      sleep 5
    #rescue => detail
    #  $logger.warn("caught exception: #{detail.message}\n#{detail.backtrace.join("\n")}")
    #end
  end
end


