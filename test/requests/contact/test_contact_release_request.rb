require 'helper'

class TestNominetContactReleaseRequest < Test::Unit::TestCase
  context 'NominetEPP::Contact::Release' do
    setup do
      @time    = Time.now.utc
      @request = NominetEPP::Contact::Release.new('sh8013', 'TESTING')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'have release element' do
      assert xpath_exists?('//r:release'), "should have release element"
    end
    
    should 'have registrant element' do
      assert_equal 'sh8013', xpath_find('//r:registrant')
    end
    
    should 'have registrarTag element' do
      assert_equal 'TESTING', xpath_find('//r:registrarTag')
    end
  end
end
