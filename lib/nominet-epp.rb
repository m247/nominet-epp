require 'epp-client'
require 'time'

require File.dirname(__FILE__) + '/operations'

module NominetEPP
  class Client
    DEFAULT_SERVICES = %w(http://www.nominet.org.uk/epp/xml/nom-domain-2.0
      http://www.nominet.org.uk/epp/xml/nom-notifications-2.0
      urn:ietf:params:xml:ns:host-1.0)

    def initialize(tag, passwd, server = 'epp.nominet.org.uk')
      @tag, @server = tag, server
      @client = EPP::Client.new(tag, passwd, server, :services => DEFAULT_SERVICES)
    end
    def inspect
      "#<#{self.class} #{@tag}@#{@server}>"
    end

    include Operations::Check
    # include Operations::Create
    include Operations::Delete
    include Operations::Fork
    # include Operations::Hello
    # include Operations::Info
    include Operations::List
    # include Operations::Lock
    # include Operations::Merge
    # include Operations::Poll
    include Operations::Renew
    # include Operations::Transfer
    # include Operations::Unlock
    include Operations::Unrenew
    # include Operations::Update

    private
      def data_namespaces(data)
        data.namespaces.definitions.map(&:to_s)
      end
      def domain(node_name, &block)
        node = XML::Node.new(node_name)
        node.namespaces.namespace =
          XML::Namespace.new(node, 'domain', 'http://www.nominet.org.uk/epp/xml/nom-domain-2.0')
        node['xsi:schemaLocation'] =
          "http://www.nominet.org.uk/epp/xml/nom-domain-2.0 nom-domain-2.0.xsd"

        case block.arity
        when 0
          yield
        when 1
          yield node
        when 2
          yield node, node.namespaces.first
        end

        node
      end
  end
end
