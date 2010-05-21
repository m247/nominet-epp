require 'epp-client'

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

    def check(*names)
      resp = @client.check do
        domain('check') do |node, ns|
          names.each do |name|
            node << XML::Node.new('name', name, ns)
          end
        end
      end

      return false unless resp.success?

      results = resp.data.find('//domain:name', data_namespaces(resp.data))
      if results.size > 1
        hash = {}
        results.each {|node| hash[node.content.strip] = (node['avail'] == '1') }
        hash
      else
        results.first['avail'] == '1'
      end
    end

    def list(type, date, fields = 'none')
      raise ArgumentError, "type must be :expiry or :month" unless [:expiry, :month].include?(type)

      date = date.strftime("%Y-%m") if date.respond_to?(:strftime)
      resp = @client.info do
        domain('list') do |node, ns|
          node << XML::Node.new(type, date, ns)
          node << XML::Node.new('fields', fields, ns)
        end
      end

      return nil unless resp.success?

      resp.data.find('//domain:name', data_namespaces(resp.data)).map do |node|
        node.content.strip
      end
    end

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
