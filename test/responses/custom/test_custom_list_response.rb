require 'helper'

class TestNominetCustomListResponse < Test::Unit::TestCase
  context 'NominetEPP::Custom::List' do
    context 'empty' do
      setup do
        @list_response = NominetEPP::Custom::ListResponse.new(load_response('custom/list_empty'))
      end

      should 'be successful' do
        assert @list_response.success?
        assert_equal 1000, @list_response.code
      end

      should 'have message' do
        assert_equal 'Command completed successfully', @list_response.message
      end
      
      should 'have no domains' do
        assert_equal 0, @list_response.domains.count
      end
    end
    context 'not empty' do
      setup do
        @list_response = NominetEPP::Custom::ListResponse.new(load_response('custom/list'))
      end

      should 'be successful' do
        assert @list_response.success?
        assert_equal 1000, @list_response.code
      end

      should 'have message' do
        assert_equal 'Command completed successfully', @list_response.message
      end

      should 'have domains' do
        expected = %w(epp-example1.co.uk epp-example2.co.uk epp-example3.co.uk
          epp-example4.co.uk epp-example5.co.uk epp-example6.co.uk)
        assert_equal expected, @list_response.domains
      end
    end
  end
end
