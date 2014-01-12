execute do |params|
  
  @op.flush_cache()
  
  @op.list_machines.each do |m|
    @op.with_machine(m["name"]) do |machine|
      machine.crawl_machine
    end
  end
end
