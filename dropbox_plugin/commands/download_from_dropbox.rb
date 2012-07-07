description "retrieves the specified file from dropbox and writes it into the filesystem of the specified machine"

execute do |params|
out,metadata = @client.get_file_and_metadata('/' + src)
end