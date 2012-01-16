class Gems < PluginBase
  
  def depends_on
    [ Core ]
  end
  
  module Gems::GemsHelper
    
    include Core::CoreHelper
    
  end
  
end