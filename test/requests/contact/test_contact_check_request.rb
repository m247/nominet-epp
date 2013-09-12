require 'helper'

class TestNominetContactCheckRequest < Test::Unit::TestCase
  context 'NominetEPP::Contact::Check' do
    setup do
      @request = NominetEPP::Contact::Check.new('sh8013', 'sh8018')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'include names' do
      names = []
      xpath_each('//contact:id') do |node|
        names << node.content.strip
      end

      assert_equal %w(sh8013 sh8018), names
    end
  end
end
