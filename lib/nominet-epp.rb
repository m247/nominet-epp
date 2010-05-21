require 'epp-client'
require 'time'

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
    # Returns the new expiry date of the provided +name+
    def renew(name, period = '2y')
      period = '2y'  # reset period to 2 years as nominet don't currently support other options

      unit = period[-1..1]
      num = period.to_i.to_s

      raise ArgumentError, "period suffix must either be 'm' or 'y'" unless %w(m y).include?(unit)

      resp = @client.renew do
        domain('renew') do |node, ns|
          node << XML::Node.new('name', name, ns)
          p = XML::Node.new('period', num, ns);
          p['unit'] = unit
          node << p
        end
      end

      return false unless resp.success?

      renData = resp.data.find('//domain:renData', data_namespaces(resp.data)).first
      renName = renData.find('domain:name', data_namespaces(resp.data)).first.content.strip
      renExp  = renData.find('domain:exDate', data_namespaces(resp.data)).first.content.strip

      raise "Renewed name #{renName} does not match #{name}" if renName != name
      return Time.parse(renExp)
    end
    def unrenew(*names)
      resp = @client.unrenew do
        domain('unrenew') do |node, ns|
          names.each do |name|
            node << XML::Node.new('name', name, ns)
          end
        end
      end

      return false unless resp.success?

      hash = {}
      resp.data.find('//domain:renData', data_namespaces(resp.data)).each do |node|
        renName = node.find('domain:name', data_namespaces(resp.data)).first.content.strip
        renExp  = node.find('domain:exDate', data_namespaces(resp.data)).first.content.strip
        hash[renName] = Time.parse(renExp)
      end
      hash
    end
    def delete(name)
      resp = @client.delete do
        domain('delete') do |node, ns|
          node << XML::Node.new('name', name, ns)
        end
      end

      resp.success?
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
