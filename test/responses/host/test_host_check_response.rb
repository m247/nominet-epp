require 'helper'

class TestNominetHostCheckResponse < Test::Unit::TestCase
  context 'NominetEPP::Host::Check' do
    setup do
      @check_response = NominetEPP::Host::CheckResponse.new(load_response('host/check'))
    end

    should 'be successful' do
      assert @check_response.success?
      assert_equal 1000, @check_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @check_response.message
    end

    should 'list ns3.beatrice-testing.co.uk as available' do
      assert @check_response.available?('ns3.beatrice-testing.co.uk')
      assert !@check_response.unavailable?('ns3.beatrice-testing.co.uk')
    end

    should 'list ns1.beatrice-testing.co.uk as unavailable' do
      assert @check_response.unavailable?('ns1.beatrice-testing.co.uk')
      assert !@check_response.available?('ns1.beatrice-testing.co.uk')
    end
  end
end
