param! 'data', 'the data lines that should be parsed', :allows_multiple_values => true

param! 'parser', 'a parser that should be used', :lookup_method => lambda { @op.list_parsers.map { |x| x['name'] }}

accept_extra_params

execute do |params|
  #parser = @op.list_parsers.select { |x| x['name'] == params['parser'] }.first
  #puts "parse_logdata - +++"
  #pp params['data']
  p = {'data' => params['data']}
  p.merge!(params['extra_params']) if params['extra_params']
  @op.send("parse_#{params['parser']}", p).select { |x| x }
end
