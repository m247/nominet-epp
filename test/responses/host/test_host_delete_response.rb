require 'helper'

class TestNominetHostDeleteResponse < Test::Unit::TestCase
  context 'NominetEPP::Host::Delete' do
    setup do
      @delete_response = NominetEPP::Host::DeleteResponse.new(load_response('host/delete'))
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
