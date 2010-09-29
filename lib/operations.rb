module NominetEPP
  # Module to enclose the Operations
  module Operations
    autoload :Check,    File.dirname(__FILE__) + '/operations/check.rb'
    autoload :Create,   File.dirname(__FILE__) + '/operations/create.rb'
    autoload :Delete,   File.dirname(__FILE__) + '/operations/delete.rb'
    autoload :Fork,     File.dirname(__FILE__) + '/operations/fork.rb'
    autoload :Hello,    File.dirname(__FILE__) + '/operations/hello.rb'
    autoload :Info,     File.dirname(__FILE__) + '/operations/info.rb'
    autoload :List,     File.dirname(__FILE__) + '/operations/list.rb'
    autoload :Lock,     File.dirname(__FILE__) + '/operations/lock.rb'
    autoload :Merge,    File.dirname(__FILE__) + '/operations/merge.rb'
    autoload :Poll,     File.dirname(__FILE__) + '/operations/poll.rb'
    autoload :Renew,    File.dirname(__FILE__) + '/operations/renew.rb'
    autoload :Transfer, File.dirname(__FILE__) + '/operations/transfer.rb'
    autoload :Unlock,   File.dirname(__FILE__) + '/operations/unlock.rb'
    autoload :Unrenew,  File.dirname(__FILE__) + '/operations/unrenew.rb'
    autoload :Update,   File.dirname(__FILE__) + '/operations/update.rb'
  end
end
