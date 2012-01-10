#require 'bash/bash'

class DropDirProvider
  
  #include Bash::BashHelper
  
  def initialize(virtualop, options)
    @op = virtualop
    @options = options
    
    # TODO check options
  end
  
  # accepts an params array (the same one passed in to the job's execute() method)
  # and writes it's content as a yaml file into the dropdir
  # the first parameter is used for the filename (and therefore must be a valid unix filename)
  def write_params_to_file(command, params)
    param_defs = command.params
      
    raise "could not get command's parameters" unless param_defs != nil
    $logger.info "command : #{command.name}"
    $logger.info "first param : #{param_defs.first.name}"
    $logger.info "params: #{params}"
    $logger.info "options : #{@options}"
      
    # write it
    options = @options
    # TODO with_host resp. on_host swallow the user param
    @op.with_machine("localhost") do |host|
      host.mkdir("dir_name" => options[:directory])
      host.write_file "target_filename" => options[:directory] + "/" + params[param_defs.first.name] + ".conf",
        "content" => params.to_yaml 
    end
    
  end
  
  def read_local_dropdir()
    result = []
    options = @options
    begin
      Dir.foreach(options[:directory]) do |file_name|
        next if /^\./.match(file_name)
        full_name = File.join(options[:directory], file_name)
        File.open(full_name, "r") do |file|
          result << YAML.load(file)
        end
      end
    rescue RuntimeError => e
      $logger.warn("got a problem reading dropdir #{options[:directory]} on #{options[:host]} (user : #{options[:user]}) : #{e.message}")
    end
    result
  end
  
  def read_dropdir_entries(command, params)
    result = []
    options = @options
    begin
      @op.with_machine("localhost") do |machine|
        with_files(machine, options[:directory], "*.conf", options[:user]) do |file|
          file_content = machine.ssh_and_check_result("user" => options[:user], "command" => "cat #{options[:directory]}/#{file}")
          
          #file_content = host.ssh_and_check_result("command" => "cat #{options[:directory]}/#{file}")
          config = YAML.load(file_content)        
          result << config
        end
      end
    rescue RuntimeError => e
      $logger.warn("got a problem reading dropdir #{options[:directory]} on #{options[:host]} (user : #{options[:user]}) : #{e.message}")
    end
    result
  end
  
end