require 'epp-client'
require 'time'

require File.dirname(__FILE__) + '/nominet-epp/version'
require File.dirname(__FILE__) + '/nominet-epp/operations'
require File.dirname(__FILE__) + '/nominet-epp/helpers'

# Nominet EPP Module
module NominetEPP
  # Front end interface Client to the NominetEPP Service
  class Client
    # Standard EPP Services to be used
    SERVICE_URNS = EPP::Client::DEFAULT_SERVICES

    # Additional Nominet specific service extensions
    SERVICE_EXTENSION_URNS = %w(
      urn:ietf:params:xml:ns:secDNS-1.1
      http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2
      http://www.nominet.org.uk/epp/xml/contact-nom-ext-1.0
      http://www.nominet.org.uk/epp/xml/std-notifications-1.2
      http://www.nominet.org.uk/epp/xml/std-handshake-1.0
      http://www.nominet.org.uk/epp/xml/std-warning-1.1
      http://www.nominet.org.uk/epp/xml/std-release-1.0)

    # Create a new instance of NominetEPP::Client
    #
    # @param [String] tag Nominet TAG
    # @param [String] passwd Nominet TAG EPP Password
    # @param [String] server Nominet EPP Server address (nil forces default)
    # @param [String] address_family 'AF_INET' or 'AF_INET6' or either of the
    #                 appropriate socket constants. Will cause connections to be
    #                 limited to this address family. Default try all addresses.
    def initialize(tag, passwd, server = 'epp.nominet.org.uk', address_family = nil)
      @tag, @server = tag, (server || 'epp.nominet.org.uk')
      @client = EPP::Client.new(tag, passwd, server, :services => SERVICE_URNS,
        :extensions => SERVICE_EXTENSION_URNS, :address_family => address_family)
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
    def namespaces(name = nil)
      @namespaces ||= begin
        (SERVICE_URNS + SERVICE_EXTENSION_URNS).inject({}) do |ns, urn|
          ns[namespace_name(urn)] = urn
          ns
        end
      end

      return @namespaces if name.nil?
      return @namespaces[name.to_sym]
    end

    # @return [Hash] Nominet Schema Locations by prefix
    def schemaLocations
      @schemaLocations ||= begin
        namespaces.inject({}) do |schema, ns|
          name, urn = ns
          schema[name] = "#{urn} #{schema_name(urn)}.xsd"
          schema
        end
      end
    end

    include Helpers

    include Operations::Check
    include Operations::Create
    include Operations::Delete
    include Operations::Handshake
    include Operations::Hello
    include Operations::Info
    include Operations::Poll
    include Operations::Release
    include Operations::Renew
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
      # @param [Symbol] ns_name Namespace name in +namespaces+ if it doesn't match +ns_prefix+.
      # @yield [node, ns] block to populate node
      # @yieldparam [XML::Node] node XML Node to populate
      # @yieldparam [XML::Namespace] ns XML Namespace of the node
      # @return [XML::Node] newly created node
      def new_node(name, ns_prefix, ns_name = ns_prefix, &block)
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
      # @return [XML::Node] new node in :contact namespace
      # @see new_node
      def contact(node_name, &block)
        new_node(node_name, :contact, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :notification namespace
      # @see new_node
      def notification(node_name, &block)
        new_node(node_name, :n, :"std-notifications", &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :release namespace
      # @see new_node
      def release(node_name, &block)
        new_node(node_name, :r, :"std-release", &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :handshake namespace
      # @see new_node
      def handshake(node_name, &block)
        new_node(node_name, :h, :"std-handshake", &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :host namespace
      # @see new_node
      def host(node_name, &block)
        new_node(node_name, :host, &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :domain-ext namespace
      # @see new_node
      def domain_ext(node_name, &block)
        new_node(node_name, :"domain-nom-ext", :"domain-ext", &block)
      end

      # @param [String] node_name XML Element name
      # @yield [node, ns] block to populate node
      # @return [XML::Node] new node in :domain-ext namespace
      # @see new_node
      def contact_ext(node_name, &block)
        new_node(node_name, :"contact-nom-ext", :"contact-ext", &block)
      end

      def namespace_name(urn)
        case urn
        when /\Aurn\:/
          urn.split(':').last.split('-',2).first.to_sym
        else
          urn.split('/').last.split('-')[0...-1].join('-').to_sym
        end
      end
      def schema_name(urn)
        case urn
        when /\Aurn\:/
          urn.split(':').last
        else
          urn.split('/').last
        end
      end
  end
end
