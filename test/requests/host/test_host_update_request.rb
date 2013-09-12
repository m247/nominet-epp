require 'helper'

class TestNominetHostUpdateRequest < Test::Unit::TestCase
  context 'NominetEPP::Host::Update' do
    setup do
      @time    = Time.now.utc
      @request = NominetEPP::Host::Update.new('ns1.example.co.uk',
        :add => {
          :addr => {:ipv4 => "198.51.100.53", :ipv6 => "2001:db8::53:1"}},
        :rem => {
          :addr => {:ipv4 => "198.51.100.54", :ipv6 => "2001:db8::53:2"}},
        :chg => {
          :name => "ns2.example.co.uk" })
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'have update element' do
      assert xpath_exists?('//host:update'), "should have update element"
    end

    should 'have name element' do
      assert_equal 'ns1.example.co.uk', xpath_find('//host:name')
    end

    should 'add IPv4 address' do
      assert_equal "198.51.100.53", xpath_find('//host:add/host:addr[@ip="v4"]')
    end
    
    should 'add IPv6 address' do
      assert_equal "2001:db8::53:1", xpath_find('//host:add/host:addr[@ip="v6"]')
    end

    should 'remove IPv4 address' do
      assert_equal "198.51.100.54", xpath_find('//host:rem/host:addr[@ip="v4"]')
    end
    
    should 'remove IPv6 address' do
      assert_equal "2001:db8::53:2", xpath_find('//host:rem/host:addr[@ip="v6"]')
    end
    
    should 'change name' do
      assert_equal 'ns2.example.co.uk', xpath_find('//host:chg/host:name')
    end

    should 'not have extension element' do
      assert !xpath_exists?('//epp:extension'), "should not have extension element"
    end
  end
end
