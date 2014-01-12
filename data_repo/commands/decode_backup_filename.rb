description "extracts structured information from a backup filename"

param! "filename", "the filename to decode"

mark_as_read_only

add_columns [ "name", "type", "date", "host", "service", "alias" ]

execute do |params|
  result = []
  matcher = /((db|file)_backup-(.*?))(\.tgz)?$/.match(params["filename"])
  if matcher then
    # TODO this fails for machine names with underscores
    name_components = matcher.captures[2].split("-")
    result_hash = {
      "type" => matcher.captures[1],
      "name" => "" + matcher.captures[0],
      "date" => name_components.last
    }
    result_hash["host"] = "" + name_components[0].to_s if name_components.size > 1

    if name_components.size > 2
      1.upto(name_components.size - 2) do |idx|
        if result_hash.has_key?('service')
          result_hash["service"] += '_' + name_components[idx].to_s
        else
          result_hash["service"] = name_components[idx].to_s
        end
      end
    end
    
    if matched = /(.+)\.(.+)/.match(result_hash["service"])
      result_hash["alias"] = matched.captures.last
      result_hash["service"] = matched.captures.first
    end
    
    result << result_hash        
  end
  result
end
