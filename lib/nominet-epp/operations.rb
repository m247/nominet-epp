module NominetEPP
  # Module to enclose the Operations
  module Operations
    autoload :Check,    File.dirname(__FILE__) + '/operations/check.rb'
    autoload :Create,   File.dirname(__FILE__) + '/operations/create.rb'
    autoload :Delete,   File.dirname(__FILE__) + '/operations/delete.rb'
    autoload :Handshake,File.dirname(__FILE__) + '/operations/handshake.rb'
    autoload :Hello,    File.dirname(__FILE__) + '/operations/hello.rb'
    autoload :Info,     File.dirname(__FILE__) + '/operations/info.rb'
    autoload :Poll,     File.dirname(__FILE__) + '/operations/poll.rb'
    autoload :Release,  File.dirname(__FILE__) + '/operations/release.rb'
    autoload :Renew,    File.dirname(__FILE__) + '/operations/renew.rb'
    autoload :Update,   File.dirname(__FILE__) + '/operations/update.rb'
  end
end
