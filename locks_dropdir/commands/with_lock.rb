param! "name", "name/alias for the lock"

param! "block", "something to do while something else is locked"

accept_extra_params

execute do |params|
  puts "getting lock #{params["name"]}"
  
  p = params.clone
  p.delete("block")
  lock = @op.get_lock(p) || raise("could not get lock")
  
  begin
    params["block"].call()
  ensure
    puts "done with lock #{params["name"]}"
    @op.release_lock(lock["dropdir_filename"])
  end
  
end
