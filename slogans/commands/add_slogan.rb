param! "slogan", "the slogan itself. text data, that is"

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params, 'slogan_' + Time.now().to_i.to_s)
end
