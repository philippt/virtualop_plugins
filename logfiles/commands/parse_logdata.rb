param! 'data', 'the data lines that should be parsed', :allows_multiple_values => true

param! 'parser', 'a parser that should be used', :lookup_method => lambda { @op.list_parsers.map { |x| x['name'] }}

execute do |params|
  #parser = @op.list_parsers.select { |x| x['name'] == params['parser'] }.first
  #puts "parse_logdata - +++"
  #pp params['data']
  @op.send("parse_#{params['parser']}", {'data' => params['data']}).select { |x| x }
end
