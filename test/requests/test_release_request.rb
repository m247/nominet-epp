require 'helper'

class TestNominetReleaseRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Release' do
    setup do
      @time    = Time.now.utc
      @request = NominetEPP::Domain::Release.new('example.co.uk', 'TESTING')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'have release element' do
      assert xpath_exists?('//r:release'), "should have release element"
    end
    
    should 'have domainName element' do
      assert_equal 'example.co.uk', xpath_find('//r:domainName')
    end
    
    should 'have registrarTag element' do
      assert_equal 'TESTING', xpath_find('//r:registrarTag')
    end
  end
end
