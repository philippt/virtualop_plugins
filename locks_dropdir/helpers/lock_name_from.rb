def lock_name_from(params)
  file_name = params["name"]  
  params["extra_params"].keys.sort.each do |k|
    v = params["extra_params"][k] 
    file_name += "_#{k}_#{v}"
  end unless params["extra_params"] == nil
  file_name
end
