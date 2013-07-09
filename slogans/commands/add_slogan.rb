param! "slogan", "the slogan itself. text data, that is"
param "alternative_html", "if the slogan should be displayed differently when viewed as HTML, specify the version to display here"

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params, 'slogan_' + Time.now().to_i.to_s)
end
