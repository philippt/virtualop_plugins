display_type :list

mark_as_read_only

execute do |params|
  service_plugins = @op.list_all_plugins("tag_filter" => "canned_services").select { |x| x["active"] }.map { |x| x["name"] }

  result = []
  @op.with_machine('localhost') do |localhost|
    config_string("descriptor_dirs").each do |dir|
      localhost.find("path" => dir, "path_filter" => "*/services/*.rb").each do |file|
        file.chomp!
        if /([^\/]+)\/services\/([^\/]+)\.rb/.match(file)
          if service_plugins.include? $1
            result << "#{$1}/#{$2}"
          end
        end
      end
    end

  end

  result.sort
end
