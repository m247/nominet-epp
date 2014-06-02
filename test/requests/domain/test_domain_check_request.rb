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

  context 'NominetEPP::Domain::Check Direct Rights' do
    context 'registrant' do
      setup do
        @request = NominetEPP::Domain::Check.new('example.uk', :registrant => '239r79343')
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'include name' do
        names = []
        xpath_each('//domain:name') do |node|
          names << node.content.strip
        end

        assert_equal %w(example.uk), names
      end

      should 'include direct-rights extension' do
        assert xpath_exists?('//nom-direct-rights:check'), "should have extension create element"
      end

      should 'have registrant element' do
        assert_equal '239r79343', xpath_find('//nom-direct-rights:registrant')
      end
    end

    context 'postal info & email' do
      setup do
        @request = NominetEPP::Domain::Check.new('example.uk',
          :email       => "enoch.root@test.host",
          :postal_info => {
            :org       => "Epiphyte",
            :name      => "Enoch Root",
            :addr      => {
              :street  => "1 Test Avenue",
              :city    => "Testington",
              :sp      => "Testshire",
              :pc      => "TE57 1NG",
              :cc      => "GB" } })
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'include name' do
        names = []
        xpath_each('//domain:name') do |node|
          names << node.content.strip
        end

        assert_equal %w(example.uk), names
      end

      should 'include direct-rights extension' do
        assert xpath_exists?('//nom-direct-rights:check'), "should have extension create element"
      end

      should 'set email' do
        assert_equal "enoch.root@test.host", xpath_find('//nom-direct-rights:email')
      end
      should 'set organisation' do
        assert_equal "Epiphyte", xpath_find('//nom-direct-rights:postalInfo/contact:org')
      end
      should 'set name' do
        assert_equal "Enoch Root", xpath_find('//nom-direct-rights:postalInfo/contact:name')
      end
      should 'set address' do
        assert_equal "1 Test Avenue", xpath_find('//nom-direct-rights:postalInfo/contact:addr/contact:street')
        assert_equal "Testington", xpath_find('//nom-direct-rights:postalInfo/contact:addr/contact:city')
        assert_equal "Testshire", xpath_find('//nom-direct-rights:postalInfo/contact:addr/contact:sp')
        assert_equal "TE57 1NG", xpath_find('//nom-direct-rights:postalInfo/contact:addr/contact:pc')
        assert_equal "GB", xpath_find('//nom-direct-rights:postalInfo/contact:addr/contact:cc')
      end
    end

    context 'argument errors' do
      should 'raise argument error if rights requested with multiple names' do
        assert_raises ArgumentError do
          NominetEPP::Domain::Check.new('example.uk', 'example2.uk',
            :registrant => '239r79343')
        end
      end

      should 'raise argument error if registrant given with other keys' do
        assert_raises ArgumentError do
          NominetEPP::Domain::Check.new('example.uk',
            :registrant => '239r79343', :email => 'example@example.co.uk')
        end
      end

      should 'raise argument error if postal info given without email' do
        assert_raises ArgumentError do
          NominetEPP::Domain::Check.new('example.uk',
            :postal_info => { :name => "Joe Bloggs" })
        end
      end

      should 'raise argument error if email given without postal info' do
        assert_raises ArgumentError do
          NominetEPP::Domain::Check.new('example.uk',
            :email => 'example@example.co.uk')
        end
      end
    end
  end
end
