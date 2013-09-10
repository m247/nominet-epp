require 'helper'

class TestNominetUnrenewRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Unrenew' do
    setup do
      @time    = Time.now.utc
      @request = NominetEPP::Domain::Unrenew.new('example.co.uk', 'example.me.uk')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'have unrenew element' do
      assert xpath_exists?('//u:unrenew'), "should have unrenew element"
    end
    
    should 'have domainName elements' do
      expected = ['example.co.uk', 'example.me.uk']
      actual   = []

      xpath_each('//u:domainName') do |node|
        actual << node.content.strip
      end

      assert_equal expected, actual
    end
  end
end
