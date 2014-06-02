require 'helper'

class TestNominetContactCreateResponse < Test::Unit::TestCase
  context 'NominetEPP::Contact::Create' do
    setup do
      @create_response = NominetEPP::Contact::CreateResponse.new(load_response('contact/create'))
    end

    should 'be successful' do
      assert @create_response.success?
      assert_equal 1000, @create_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @create_response.message
    end

    should 'have name UK-4398495' do
      assert_equal 'UK-4398495', @create_response.name
    end

    should 'have new creation date' do
      # 2013-09-13T15:48:52 - local time, not UTC
      expected = Time.mktime(2013,9,13,15,48,52)
      assert_equal expected, @create_response.creation_date
    end
  end
end
