require 'helper'

class TestNominetDomainCheckRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Check' do
    setup do
      @request = NominetEPP::Domain::Check.new('example.co.uk', 'example.me.uk')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'include names' do
      names = []
      xpath_each('//domain:name') do |node|
        names << node.content.strip
      end

      assert_equal %w(example.co.uk example.me.uk), names
    end
  end
end
