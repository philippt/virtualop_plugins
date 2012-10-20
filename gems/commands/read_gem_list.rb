description 'reads a list of ruby gems as the one returned by "gem list"'

display_type :table
add_column :name
add_column :version

#param "input", "the list as one string with newlines"
param! "lines", "lines from a package file", :allows_multiple_values => true

execute do |params|
  result = []
  params["lines"].each do |line|
    # TODO make version optional
    matched = /(.+)\s\(([\d\.]+)\)/.match(line)
    if matched
      result << {
        "name" => matched.captures[0],
        "version" => matched.captures[1]
      }
    end
  end
  result
end