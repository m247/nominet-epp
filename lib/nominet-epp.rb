require 'epp-client'
require 'time'

require File.dirname(__FILE__) + '/nominet-epp/version'
require File.dirname(__FILE__) + '/nominet-epp/operations'
require File.dirname(__FILE__) + '/nominet-epp/helpers'

require File.dirname(__FILE__) + '/nominet-epp/client'
require File.dirname(__FILE__) + '/nominet-epp/request'
require File.dirname(__FILE__) + '/nominet-epp/notification'

require File.dirname(__FILE__) + '/nominet-epp/requests/custom/list'
require File.dirname(__FILE__) + '/nominet-epp/requests/custom/handshake'
require File.dirname(__FILE__) + '/nominet-epp/requests/custom/tag_list'

require File.dirname(__FILE__) + '/nominet-epp/requests/domain/check'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/create'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/delete'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/info'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/release'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/renew'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/unrenew'
require File.dirname(__FILE__) + '/nominet-epp/requests/domain/update'

require File.dirname(__FILE__) + '/nominet-epp/requests/contact/check'
require File.dirname(__FILE__) + '/nominet-epp/requests/contact/create'
require File.dirname(__FILE__) + '/nominet-epp/requests/contact/delete'
require File.dirname(__FILE__) + '/nominet-epp/requests/contact/info'
require File.dirname(__FILE__) + '/nominet-epp/requests/contact/release'
require File.dirname(__FILE__) + '/nominet-epp/requests/contact/update'

require File.dirname(__FILE__) + '/nominet-epp/requests/host/check'
require File.dirname(__FILE__) + '/nominet-epp/requests/host/create'
require File.dirname(__FILE__) + '/nominet-epp/requests/host/delete'
require File.dirname(__FILE__) + '/nominet-epp/requests/host/info'
require File.dirname(__FILE__) + '/nominet-epp/requests/host/update'

require File.dirname(__FILE__) + '/nominet-epp/responses/custom/list_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/custom/handshake_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/custom/tag_list_response'

require File.dirname(__FILE__) + '/nominet-epp/responses/domain/check_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/create_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/delete_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/info_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/release_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/renew_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/unrenew_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/domain/update_response'

require File.dirname(__FILE__) + '/nominet-epp/responses/contact/check_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/contact/create_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/contact/delete_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/contact/info_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/contact/release_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/contact/update_response'

require File.dirname(__FILE__) + '/nominet-epp/responses/host/check_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/host/create_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/host/delete_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/host/info_response'
require File.dirname(__FILE__) + '/nominet-epp/responses/host/update_response'

# Nominet EPP Module
module NominetEPP

  autoload :LogSubscriber, File.expand_path('../nominet-epp/log_subscriber.rb', __FILE__)

end
