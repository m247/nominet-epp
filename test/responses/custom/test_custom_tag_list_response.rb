require 'helper'

class TestNominetCustomTagListResponse < Test::Unit::TestCase
  context 'NominetEPP::Custom::TagList' do
    setup do
      @tag_list_response = NominetEPP::Custom::TagListResponse.new(load_response('custom/tag_list'))
    end

    should 'be successful' do
      assert @tag_list_response.success?
      assert_equal 1000, @tag_list_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @tag_list_response.message
    end

    should 'have tags' do
      expected = %w(EXAMPLE-TAG EXAMPLE2-TAG)
      names = @tag_list_response.tags.keys.sort

      assert_equal expected, names
    end
    
    should 'have EXAMPLE-TAG data' do
      data = @tag_list_response.tags['EXAMPLE-TAG']
      expected = {
        'name' => 'Example company name',
        'trad_name' => 'Example trading name',
        'handshake' => true }

      assert_equal expected, data
    end
    should 'have EXAMPLE2-TAG data' do
      data = @tag_list_response.tags['EXAMPLE2-TAG']
      expected = {
        'name' => 'Example2 company name',
        'handshake' => false }

      assert_equal expected, data
    end
  end
end
