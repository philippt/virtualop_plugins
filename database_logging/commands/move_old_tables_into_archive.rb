description "moves old database logging tables into an tarball archive (drops the original tables)"

execute do |params|
  @op.find_old_tables.each do |table_name|
    @op.move_table_into_archive("table_name" => table_name)
  end
end  