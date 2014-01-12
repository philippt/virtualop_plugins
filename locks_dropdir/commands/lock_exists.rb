param! "name", "name/alias for the lock"

accept_extra_params

execute do |params|
  result = nil
  file_name = lock_name_from params
  
  @op.without_cache do
    result = @op.list_locks.select do |lock|
      lock["dropdir_filename"] == file_name 
    end
  end
  result
end
