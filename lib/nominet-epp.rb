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
    def namespaces
      { :domain  => 'http://www.nominet.org.uk/epp/xml/nom-domain-2.0',
        :account => 'http://www.nominet.org.uk/epp/xml/nom-account-2.0',
        :contact => 'http://www.nominet.org.uk/epp/xml/nom-contact-2.0',
        :tag     => 'http://www.nominet.org.uk/epp/xml/nom-tag-1.0',
        :n       => 'http://www.nominet.org.uk/epp/xml/nom-notifications-2.0' }
    end
    def schemaLocations
      { :domain  => 'http://www.nominet.org.uk/epp/xml/nom-domain-2.0 nom-domain-2.0.xsd',
        :account => 'http://www.nominet.org.uk/epp/xml/nom-account-2.0 nom-account-2.0.xsd',
        :contact => 'http://www.nominet.org.uk/epp/xml/nom-contact-2.0 nom-contact-1.0.xsd',
        :tag     => 'http://www.nominet.org.uk/epp/xml/nom-tag-1.0 nom-tag-1.0.xsd',
        :n       => 'http://www.nominet.org.uk/epp/xml/nom-notifications-2.0  nom-notifications-2.0.xsd' }
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
    include Operations::Poll
    include Operations::Renew
    include Operations::Transfer
    include Operations::Unlock
    include Operations::Unrenew
    include Operations::Update

    private
      def node_value(node, xpath)
        n = node.find(xpath, namespaces).first
        n && n.content.strip
      end
      def new_node(name, ns_prefix, &block)
        node = XML::Node.new(name)
        node.namespaces.namespace = ns = XML::Namespace.new(node, ns_prefix.to_s, namespaces[ns_prefix])
        node['xsi:schemaLocation'] = schemaLocations[ns_prefix]

        case block.arity
        when 0
          yield
        when 1
          yield node
        when 2
          yield node, ns
        end

        node
      end
      def domain(node_name, &block)
        new_node(node_name, :domain, &block)
      end
      def account(node_name, &block)
        new_node(node_name, :account, &block)
      end
      def contact(node_name, &block)
        new_node(node_name, :contact, &block)
      end
      def tag(node_name, &block)
        new_node(node_name, :tag, &block)
      end
      def notification(node_name, &block)
        new_node(node_name, :n, &block)
      end
  end
end
