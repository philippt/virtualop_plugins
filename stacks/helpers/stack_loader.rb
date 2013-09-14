class StackLoader
  
  attr_reader :stacks
  
  def initialize(op, plugin)
    @op = op
    @plugin = plugin
    @stacks = []
    
    plugin.load_helper_classes(self) unless plugin == nil
    #@command_loader = CommandLoader.new()
  end
  
  def new_stack(name)
    @stack = { 
      "name" => name,
      "machines" => [],
      "blocks" => {}
    }
    @stacks << @stack
    stack_name = @stack["name"]
    
    @install_command = RHCP::Command.new("stacks." + stack_name + "_stackinstall", "installs the stack #{stack_name}")
    @install_command.add_param(param_machine)
    @install_command.add_param(RHCP::CommandParam.new("extra_params", "a hash of extra parameters for the stack install command"))
    @install_command.accept_extra_params
    begin
      @op.local_broker.register_command(@install_command)
    rescue => ex
      raise ex unless /duplicate/.match(ex.message)
    end
    
    @post_rollout_command = RHCP::Command.new("stacks." + stack_name + "_post_rollout", "is called after the stack #{stack_name} has been rolled out")
    @post_rollout_command.add_param(param_machine)
    @post_rollout_command.add_param(RHCP::CommandParam.new("result", "a hash holding the rollout jobs' result, grouped by status"))
    @post_rollout_command.add_param(RHCP::CommandParam.new("extra_params", "a hash of extra parameters for the post rollout command"))
    @post_rollout_command.accept_extra_params
    begin
      @op.local_broker.register_command(@post_rollout_command)
    rescue => ex
      raise ex unless /duplicate/.match(ex.message)
    end
  end
    
  def self.read(op, plugin, name, source, file_name = nil)
    loader = new(op, plugin)

    loader.new_stack(name)
    begin
      loader.instance_eval source, file_name
    rescue => detail
      puts "#{detail.message}\n#{detail.backtrace.join("\n")}"
    end

    loader
  end
  
  #---------------------------
  
  def description(s)
    @stack["description"] = s 
  end
  
  # TODO ----- this is copied from command_loader [start] ----- 
  def add_param(p)
    @install_command.add_param(p)
  end
  
  def param(name, options = {})
    param_description = options[:description] || ''
    if name.class.to_s == "Symbol"
      method_name = "param_#{name.to_s}"
      
      param_definition = case self.method(method_name.to_sym).arity
      when -2
        self.send(method_name.to_sym, param_description, options)
      when -1
        self.send(method_name.to_sym, options)
      end
      add_param param_definition
    else
      add_param RHCP::CommandParam.new(name, param_description, options)
    end
  end
  
  def param!(name, options = {})
    options.merge! :mandatory => true
    param(name, options)
  end
  
  # TODO ----- this is copied from command_loader [stop] -----
  
  def params
    {}
  end
  
  class MachineDefinition
    
    attr_accessor :name, :block
    
    attr_accessor :vm_name, :full_name

    attr_accessor :params

    attr_reader :data

    attr_reader :canned_service
    attr_reader :github_project
        
    def initialize(name, block)
      @name = name
      @block = block
      
      @vm_name = @full_name = nil
      
      @data = {}
      @params = {}
      
      self
    end
    
    # TODO load helper dynamically
        
    def canned_service(name_sym)
      @data["canned_service"] = name_sym.to_s + '/' + name_sym.to_s
    end
    
    def github(project_name, options = {})
      @data["github_project"] = project_name
      @data["git_branch"] = options[:branch] if options[:branch]
    end
    
    def domain_prefix(prefix)
      domain("#{prefix}.#{@params["domain"]}")
    end
    
    def memory(*args)
      arg = args.first
      if arg.class == Array
        @data["memory_size"] = (arg.size == 3 ? arg[1] : arg.first)
      else
        @data["memory_size"] = arg
      end
    end
    
    def disk(d)
      @data["disk_size"] = d
    end
    
    def param(key, value)
      @data[key] = value
    end
    
    def domain(d)
      @data["domain"] = d
    end

  end
  
  def stack(name_sym, &block)
    m = {
      "name" => name_sym.to_s,
      "block" => block
    }
    m = MachineDefinition.new(name_sym.to_s, block)
    @stack["machines"] << m    
  end
  
  
  
  def on_install(&block)
    # TODO that's more or less identical to CommandLoader.exceute
    @install_command.block = lambda do |request, response|
       
      p = { "stack" => @stack["name"] }
      puts "request values:"
      pp request.values
      p.merge! request.values
      p.merge! request.values["extra_params"]
      
      p.each do |k,v|
        next if k == "extra_params"
        p["extra_params"][k] = v
      end
      #p.delete("extra_params")
      #p["extra_params"] = p # TODO this must be what going mad feels like
      pp p
      stack = {}
      @op.resolve_stack(p).each do |m|
        stack[m["name"]] = [] unless stack.has_key? m["name"]
        stack[m["name"]] << m
      end
      
      params = {}
    
      @install_command.params.each do |current_param|
        if request.has_param_value(current_param.name)
          params[current_param.name] = request.get_param_value(current_param.name) || p[current_param.name]
        end
      end
      
      begin
        block.call(stack, params)
      rescue => ex
        raise "could not execute installation block for stack #{@stack["name"]} : #{ex.message}\n#{ex.backtrace.join("\n")}"
      end
    end
  end
  
  def post_rollout(&block)
    # TODO let's not do that again
    @post_rollout_command.block = lambda do |request, response|
       
      p = { "stack" => @stack["name"] }
      p.merge! request.values
      p.merge! request.values["extra_params"]
      
      p.each do |k,v|
        next if k == "extra_params"
        p["extra_params"][k] = v
      end
      stack = {}
      @op.resolve_stack(p).each do |m|
        stack[m["name"]] = [] unless stack.has_key? m["name"]
        stack[m["name"]] << m
      end
      
      params = {}
    
      @post_rollout_command.params.each do |current_param|
        if request.has_param_value(current_param.name)
          params[current_param.name] = request.get_param_value(current_param.name) || p[current_param.name]
        end
      end
      
      begin
        block.call(stack, params)
      rescue => ex
        raise "could not execute post rollout block for stack #{@stack["name"]} : #{ex.message}\n#{ex.backtrace.join("\n")}"
      end
    end
  end
  
end