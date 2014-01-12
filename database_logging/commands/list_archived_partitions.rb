description "returns vop logging partitions that have been extracted into a tarball on the local machine"

display_type :list

execute do |params|
  result = []
  
  @op.with_machine('localhost') do |machine|
    machine.list_files("directory" => archive_dir(machine)).each do |file|
      if matched = /requests_((\d{4})(\d{2})(\d{2})).tgz$/.match(file)
        result << matched.captures.first
      end
    end
  end
  
  result
end
