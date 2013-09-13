require 'helper'

class TestNominetHostUpdateResponse < Test::Unit::TestCase
  context 'NominetEPP::Host::Update' do
    setup do
      @update_response = NominetEPP::Host::UpdateResponse.new(load_response('host/update'))
    end

    should 'be successful' do
      assert @update_response.success?
      assert_equal 1000, @update_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @update_response.message
    end
  end
end
