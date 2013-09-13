require 'helper'

class TestNominetHostInfoResponse < Test::Unit::TestCase
  context 'NominetEPP::Host::Info' do
    setup do
      @info_response = NominetEPP::Host::InfoResponse.new(load_response('host/info'))
    end

    should 'be successful' do
      assert @info_response.success?
      assert_equal 1000, @info_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @info_response.message
    end

    should 'have name' do
      assert_equal 'ns1.beatrice-testing.co.uk', @info_response.name
    end

    should 'have addresses' do
      expected = {'ipv4' => %w(1.2.3.4),
                  'ipv6' => %w(0001:0002:0003:0004:0005:0006:0007:0008)}
      assert_equal expected, @info_response.addresses
    end
  end
end
