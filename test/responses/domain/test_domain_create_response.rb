require 'helper'

class TestNominetDomainCreateResponse < Test::Unit::TestCase
  context 'NominetEPP::Domain::Create' do
    setup do
      @create_response = NominetEPP::Domain::CreateResponse.new(load_response('domain/create'))
    end

    should 'be successful' do
      assert @create_response.success?
      assert_equal 1000, @create_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @create_response.message
    end

    should 'have name adriana2-testing.co.uk' do
      assert_equal 'adriana2-testing.co.uk', @create_response.name
    end

    should 'have new creation date' do
      # 2013-09-13T11:42:37 - local time, not UTC
      expected = Time.mktime(2013,9,13,11,42,37)
      assert_equal expected, @create_response.creation_date
    end

    should 'have new expiration date' do
      # 2015-09-13T11:42:37 - local time, not UTC
      expected = Time.mktime(2015,9,13,11,42,37)
      assert_equal expected, @create_response.expiration_date
    end
  end
end
