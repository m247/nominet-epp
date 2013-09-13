require 'helper'

class TestNominetContactDeleteResponse < Test::Unit::TestCase
  context 'NominetEPP::Contact::Delete' do
    setup do
      @delete_response = NominetEPP::Contact::DeleteResponse.new(load_response('contact/delete'))
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
