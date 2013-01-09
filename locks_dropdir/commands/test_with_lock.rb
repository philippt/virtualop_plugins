execute do |params|
  @op.with_lock("name" => "foo", "extra_params" => { "machine" => "foo.bar.baz" }) do
    @op.comment("message" => "that was too easy")
  end
end
