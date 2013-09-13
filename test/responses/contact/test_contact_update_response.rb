require 'helper'

class TestNominetContactUpdateResponse < Test::Unit::TestCase
  context 'NominetEPP::Contact::Update' do
    setup do
      @update_response = NominetEPP::Contact::UpdateResponse.new(load_response('contact/update'))
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
