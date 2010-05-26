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
      def tag_list
        resp = @client.info do
          tag('list')
        end

        return false unless resp.success?

        resp.data.find('//tag:infData', namespaces).map do |node|
          { :registrar_tag => node_value(node, 'tag:registrar-tag'),
            :name =>          node_value(node, 'tag:name'),
            :trad_name =>     node_value(node, 'tag:trad-name'),
            :handshake =>     node_value(node, 'tag:handshake') == 'Y' }
        end
      end
    end
  end
end
