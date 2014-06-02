require 'helper'

class TestNominetHostCreateResponse < Test::Unit::TestCase
  context 'NominetEPP::Host::Create' do
    setup do
      @create_response = NominetEPP::Host::CreateResponse.new(load_response('host/create'))
    end

    should 'be successful' do
      assert @create_response.success?
      assert_equal 1000, @create_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @create_response.message
    end

    should 'have name ns3.beatrice-testing.co.uk' do
      assert_equal 'ns3.beatrice-testing.co.uk', @create_response.name
    end

    should 'have new creation date' do
      # 2013-09-13T15:28:48 - local time, not UTC
      expected = Time.mktime(2013,9,13,15,28,48)
      assert_equal expected, @create_response.creation_date
    end
  end
end
