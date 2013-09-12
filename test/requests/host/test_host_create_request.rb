require 'helper'

class TestNominetHostCreateRequest < Test::Unit::TestCase
  context 'NominetEPP::Host::Create' do
    setup do
      @request = NominetEPP::Host::Create.new('ns1.example.co.uk',
        :ipv4 => "198.51.100.53", :ipv6 => "2001:db8::53:1")
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'set name' do
      assert_equal 'ns1.example.co.uk', xpath_find('//host:name')
    end

    should 'set IPv4 address' do
      assert_equal "198.51.100.53", xpath_find('//host:addr[@ip="v4"]')
    end

    should 'set IPv6 address' do
      assert_equal "2001:db8::53:1", xpath_find('//host:addr[@ip="v6"]')
    end

    should 'not have extension element' do
      assert !xpath_exists?('//epp:extension'), "should not have extension element"
    end
  end
end
