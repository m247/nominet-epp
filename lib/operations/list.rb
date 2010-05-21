module NominetEPP
  module Operations
    module List
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
    end
  end
end
