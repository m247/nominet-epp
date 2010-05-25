require 'epp-client'
require 'time'

require File.dirname(__FILE__) + '/operations'
require File.dirname(__FILE__) + '/helpers'

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

    include Helpers

    include Operations::Check
    include Operations::Create
    include Operations::Delete
    include Operations::Fork
    include Operations::Hello
    include Operations::Info
    include Operations::List
    include Operations::Lock
    include Operations::Merge
    # include Operations::Poll
    include Operations::Renew
    # include Operations::Transfer
    include Operations::Unlock
    include Operations::Unrenew
    include Operations::Update

    private
      def data_namespaces(data)
        data.namespaces.definitions.map(&:to_s)
      end
      def node_value(node, xpath)
        n = node.find(xpath, xpath, node.namespaces.namespace.to_s).first
        n && n.content.strip
      end
      def new_node(name, ns_prefix, ns_href, schema_uri, &block)
        node = XML::Node.new(name)
        node.namespaces.namespace = XML::Namespace.new(node, ns_prefix, ns_uri)
        node['xsi:schemaLocation'] = schema_uri

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
      def domain(node_name, &block)
        new_node(node_name, 'domain', 'http://www.nominet.org.uk/epp/xml/nom-domain-2.0',
          "http://www.nominet.org.uk/epp/xml/nom-domain-2.0 nom-domain-2.0.xsd", &block)
      end
      def account(node_name, &block)
        new_node(node_name, 'account', 'http://www.nominet.org.uk/epp/xml/nom-account-2.0',
          "http://www.nominet.org.uk/epp/xml/nom-account-2.0 nom-account-2.0.xsd", &block)
      end
      def contact(node_name, &block)
        new_node(node_name, 'contact', 'http://www.nominet.org.uk/epp/xml/nom-contact-2.0',
          "http://www.nominet.org.uk/epp/xml/nom-contact-2.0 nom-contact-1.0.xsd", &block)
      end
      def tag(node_name, &block)
        new_node(node_name, 'tag', 'http://www.nominet.org.uk/epp/xml/nom-tag-1.0',
          "http://www.nominet.org.uk/epp/xml/nom-tag-1.0 nom-tag-1.0.xsd", &block)
      end
  end
end
