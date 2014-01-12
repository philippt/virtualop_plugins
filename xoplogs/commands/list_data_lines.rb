display_type :list

mark_as_read_only

execute do |params|
  %w|count_success count_errors count_total response_time_ms|
end
