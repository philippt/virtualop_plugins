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
      "machines" => [] 
    }
    @stacks << @stack
    stack_name = @stack["name"]
    @install_command = RHCP::Command.new(stack_name + "_stackinstall", "installs the stack #{stack_name}")
  end
    
  def self.read(op, plugin, name, source)
    loader = new(op, plugin)

    loader.new_stack(name)
    loader.instance_eval source

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

    attr_accessor :params

    attr_reader :data

    attr_reader :canned_service
    attr_reader :github_project
        
    def initialize(name, block)
      @name = name
      @block = block
      
      @data = {}
      @params = {}
      
      self
    end
    
    # TODO load helper dynamically
        
    def canned_service(name_sym)
      @data["canned_service"] = name_sym.to_s + '/' + name_sym.to_s
    end
    
    def github(project_name, options = {})
      @github_project = project_name
      @data["git_branch"] = options[:branch] if options[:branch]
    end
    
    def domain_prefix(prefix)
      domain("#{prefix}.#{@params["domain"]}")
    end
    
    def memory(*args)
      arg = args.first.first
      if arg.class == Array.class
        @data["memory_size"] = arg.first
      else
        @data["memory_size"] = arg
      end
    end
    
    def disk(d)
      @data["disk_size"] = d
    end
    
    def method_missing(sym, *args)
      if %w|domain|.include? sym.to_s
        value = *args.first
        value = value.to_s if value.class == Symbol.class
        @data[sym.to_s] = value        
      else
        super(sym, args)
      end
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
  
end