require 'helper'

class TestNominetDomainDeleteResponse < Test::Unit::TestCase
  context 'NominetEPP::Domain::Delete' do
    setup do
      @delete_response = NominetEPP::Domain::DeleteResponse.new(load_response('domain/delete'))
    end

    should 'be successful' do
      assert @delete_response.success?
      assert_equal 1000, @delete_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @delete_response.message
    end
  end
end
