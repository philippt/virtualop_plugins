description "returns all files contained in the specified configuration channel"

param :spacewalk_host
param :config_channel

param "content_filter", "a regular expression to filter files by content"

mark_as_read_only

add_columns [ "path", "type", "revision", "md5" ]

execute_on_spacewalk do |server, session, params|
  file_names = server.call('configchannel.listFiles', session, params["config_channel"]).map do |file|
    file["path"]
  end
      
  file_infos = server.call('configchannel.lookupFileInfo', session, params["config_channel"], file_names)
  file_infos.each do |file_info|
    file_info["channel_name"] = params["config_channel"]
  end
  
  file_infos.select do |file_info|
    if params.has_key?('content_filter')
      if file_info["type"] == "file"
        /#{params["content_filter"]}/.match(file_info["contents"])
      else
        false
      end
    else
      true  
    end
  end
end