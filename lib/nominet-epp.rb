require 'epp-client'
require 'time'

require File.dirname(__FILE__) + '/nominet-epp/version'
require File.dirname(__FILE__) + '/nominet-epp/operations'
require File.dirname(__FILE__) + '/nominet-epp/helpers'

# Nominet EPP Module
module NominetEPP
  # Front end interface Client to the NominetEPP Service
  class Client
    # Default Nominet Service URNs
    DEFAULT_SERVICES = %w(http://www.nominet.org.uk/epp/xml/nom-domain-2.0
      http://www.nominet.org.uk/epp/xml/nom-notifications-2.0
      urn:ietf:params:xml:ns:host-1.0)

    # Create a new instance of NominetEPP::Client
    #
    # @param [String] tag Nominet TAG
    # @param [String] passwd Nominet TAG EPP Password
    # @param [String] server Nominet EPP Server address
    def initialize(tag, passwd, server = 'epp.nominet.org.uk')
      @tag, @server = tag, server
      @client = EPP::Client.new(tag, passwd, server, :services => DEFAULT_SERVICES)
    end

    # @see Object#inspect
    def inspect
      "#<#{self.class} #{@tag}@#{@server}>"
    end

    # Returns the last EPP::Request sent
    #
    # @return [EPP::Request] last sent request
    def last_request
      @client._last_request
    end

    # Returns the last EPP::Response received
    #
    # @return [EPP::Response] last received response
    def last_response
      @client._last_response
    end

    # Returns the last EPP message received
    #
    # @return [String] last EPP message
    # @see #last_response
    def last_message
      last_response.message
    end

    # Returns the last Nominet failData response found
    #
    # @note This is presently only set by certain method calls,
    #       so it may not always be present.
    # @return [Hash] last failData found
    def last_error_info
      @error_info
    end

    # @return [Hash] Nominet Namespaces by prefixes
    def namespaces
      { :domain  => 'http://www.nominet.org.uk/epp/xml/nom-domain-2.0',
        :account => 'http://www.nominet.org.uk/epp/xml/nom-account-2.0',
        :contact => 'http://www.nominet.org.uk/epp/xml/nom-contact-2.0',
        :tag     => 'http://www.nominet.org.uk/epp/xml/nom-tag-1.0',
        :n       => 'http://www.nominet.org.uk/epp/xml/nom-notifications-2.0',
        :host    => 'urn:ietf:params:xml:ns:host-1.0' }
    end

    # @return [Hash] Nominet Schema Locations by prefix
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
      # @param [XML::Node] node XML Node to find the value from
      # @param [String] xpath XPath Expression for the value
      # @return [String] node value
      def node_value(node, xpath)
        n = node.find(xpath, namespaces).first
        n && n.content.strip
      end

      # @param [String] name XML Element name
      # @param [Symbol] ns_prefix Namespace Prefix
      # @yield [node, ns] block to populate node
      # @yieldparam [XML::Node] node XML Node to populate
      # @yieldparam [XML::Namespace] ns XML Namespace of the node
      # @return [XML::Node] newly created node
      def new_node(name, ns_prefix, &block)
        node = XML::Node.new(name)
        node.namespaces.namespace = ns = XML::Namespace.new(node, ns_prefix.to_s, namespaces[ns_prefix])
        node['xsi:schemaLocation'] = schemaLocations[ns_prefix] if schemaLocations.has_key?(ns_prefix)

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

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :domain namespace
      # @see new_node
      def domain(node_name, &block)
        new_node(node_name, :domain, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :account namespace
      # @see new_node
      def account(node_name, &block)
        new_node(node_name, :account, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :contact namespace
      # @see new_node
      def contact(node_name, &block)
        new_node(node_name, :contact, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :tag namespace
      # @see new_node
      def tag(node_name, &block)
        new_node(node_name, :tag, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :notification namespace
      # @see new_node
      def notification(node_name, &block)
        new_node(node_name, :n, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :host namespace
      # @see new_node
      def host(node_name, &block)
        new_node(node_name, :host, &block)
      end
  end
end
