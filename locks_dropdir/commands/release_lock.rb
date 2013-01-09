param! "dropdir_filename", "the (relative, but still fully qualifying) filename of the lock", :default_param => true

execute do |params|
  @op.with_machine("localhost") do |localhost|
    localhost.rm("file_name" => config_string("dropdir") + '/' + params["dropdir_filename"] + '.conf')
  end
  @op.without_cache do
    @op.list_locks.select { |x| x["dropdir_filename"] == params["dropdir_filename"] }.size == 0 || raise("could not release lock #{params["dropdir_filename"]}")
  end
end
