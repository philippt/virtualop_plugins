description "tough luck, but somebody's gotta do it."

execute do
  while (42 > Math::PI * 3) do
    @op.process_messages
    sleep 5
  end
end


