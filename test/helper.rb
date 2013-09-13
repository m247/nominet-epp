require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nominet-epp'
require 'epp-client/testing'

module NominetEPP
  class Client
    def prepare_request(type, request, extension = nil)
      @client.__send__(:"#{type}_prepare", request, extension)
    end
    def load_response(xml)
      @client.__send__(:load_response, xml)
    end
  end
end

class Test::Unit::TestCase
  def load_xml(name)
    xml_path = File.expand_path("../support/responses/#{name}.xml", __FILE__)
    File.read(xml_path)
  end
  def load_response(name)
    xml = load_xml(name)
    test_client.load_response(xml)
  end
  
  def load_schema(name)
    xsd_path = File.expand_path("../support/schemas/#{name}.xsd", __FILE__)
    xsd_doc  = XML::Document.file(xsd_path)
    XML::Schema.document(xsd_doc)
  end
  def schema
    @schema ||= load_schema('nom-root-std-1.0.6')
  end
  def xpath_find(query)
    n = @xml.find(query, @namespaces).first
    case n
    when XML::Node
      n.content.strip
    when XML::Attr
      n.value.strip
    end
  end
  def xpath_each(query)
    @xml.find(query, @namespaces).each do |node|
      yield node
    end
  end
  def xpath_exists?(query)
    !@xml.find(query, @namespaces).empty?
  end
  def namespaces_from_request(request = @request)
    @namespaces = Hash[*request.namespaces.map { |k,ns| [k, ns.href] }.flatten]
  end

  def test_client
    @test_client ||= NominetEPP::Client.new('TEST', 'testing')
  end

  def prepare_request(name = @request.command_name, request = @request)
    test_client.prepare_request(name, request.command, request.extension)
  end
end
