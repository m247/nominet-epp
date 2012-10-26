module NominetEPP
  module Operations
    # EPP Info Operation
    module Info
      # @param [Symbol] entity Type of entity to get information about
      # @param [String] id Identifier of the entity
      # @return [false] failed
      # @return [Hash]
      def info(entity, id)
        raise ArgumentError, "entity must be :domain, :contact or :host" unless [:domain, :contact, :host].include?(entity)

        resp = @client.info do
          case entity
          when :domain
            domain('info') { |node, ns| node << XML::Node.new('name', id, ns) }
          when :contact
            contact('info') { |node, ns| node << XML::Node.new('id', id, ns) }
          when :host
            host('info') { |node, ns| node << XML::Node.new('name', id, ns) }
          end
        end

        return false unless resp.success?
        result = self.send(:"info_#{entity}", resp.data)
        result.merge(self.send(:"info_#{entity}_extension", resp.extension))
      end

      private
        # @param [XML::Node] data Domain data
        # @return [Hash]
        def info_domain(data)
          hash = {}
          data.find('//domain:infData', namespaces).first.children.reject{|n| n.empty?}.each do |node|
            key = node.name.gsub('-', '_').to_sym
            case node.name
            when 'host'
              hash[:host] ||= Array.new
              hash[:host] << node.content.strip
            when 'ns'
              hash[:ns] = node.find('domain:hostAttr', namespaces).map do |hostAttr|
                { :name => node_value(hostAttr, 'domain:hostName'),
                  :v4 => node_value(hostAttr, 'domain:hostAddr[@ip="v4"]'),
                  :v6 => node_value(hostAddr, 'domain:hostAddr[@ip="v6"]') }
              end

              if hash[:ns].empty?
                hash[:ns] += node.find('domain:hostObj', namespaces).map do |hostObj|
                  { :name => hostObj.content.strip }
                end
              end
            when /date/i
              hash[key] = Time.parse(node.content.strip)
            else
              hash[key] = node.content.strip
            end
          end
          hash
        end
        # @param [Array<XML::Node>] extensions Domain extension data
        # @return [Hash]
        def info_domain_extension(extensions)
          hash = {}

          Array(extensions).each do |extension|
            case extension.name
            when "infData"
              extension.find('//domain-nom-ext:infData', namespaces).first.children.reject { |n| n.empty? }.each do |node|
                key = node.name.gsub('-', '_').to_sym
                hash[key] = node.content.strip
              end
            when "truncated-field"
              extension.find('//std-warning:truncated-field', namespaces).each do |node|
                fieldName = node.attributes["field-name"]
                ns, field = fieldName.split(":", 2)
                content = node.content.strip
                content =~ /Full entry is '([^']*)'/

                hash[field.to_sym] = $1
              end
            end
          end

          hash
        end

        # @param [XML::Node] data Contact data
        # @return [Hash]
        def info_contact(data)
          hash = {}
          data.find('//contact:infData', namespaces).first.children.reject{|n| n.empty?}.each do |node|
            case node.name
            when 'status'
              hash[:status] = node.attributes['s']
            when 'postalInfo'
              hash[:postal_info] = { :name => node_value(node, 'contact:name'),
                :org => node_value(node, 'contact:org'),
                :addr => {
                  :street => node_value(node, 'contact:addr/contact:street'),
                  :city => node_value(node, 'contact:addr/contact:city'),
                  :sp => node_value(node, 'contact:addr/contact:sp'),
                  :pc => node_value(node, 'contact:addr/contact:pc'),
                  :cc => node_value(node, 'contact:addr/contact:cc')
                }
              }
            when /date/i
              hash[node.name.to_sym] = Time.parse(node.content.strip)
            else
              hash[node.name.to_sym] = node.content.strip
            end
          end
          hash
        end
        # @param [Array<XML::Node>] extensions Contact extension data
        # @return [Hash]
        def info_contact_extension(extensions)
          hash = {}

          Array(extensions).each do |extension|
            case extension.name
            when "infData"
              extension.find('//contact-nom-ext:infData', namespaces).first.children.reject { |n| n.empty? }.each do |node|
                key = node.name.gsub('-', '_').to_sym
                case key
                when :opt_out
                  hash[key] = node.content.strip == 'Y'
                else
                  hash[key] = node.content.strip
                end
              end
            when "truncated-field"
              extension.find('//std-warning:truncated-field', namespaces).each do |node|
                fieldName = node.attributes["field-name"]
                ns, field = fieldName.split(":", 2)
                content = node.content.strip
                content =~ /Full entry is '([^']*)'/

                hash[field.to_sym] = $1
              end
            end
          end

          hash
        end

        # @param [XML::Node] data Host data
        # @return [Hash]
        def info_host(data)
          hash = {}
          data.find('//host:infData', namespaces).first.children.reject{|n| n.empty?}.each do |node|
            case node.name
            when 'status'
              hash[:status] = node.attributes['s']
            when 'addr'
              hash[:addr] ||= {}

              family = node.attributes["ip"].to_sym
              hash[:addr][family] = node.content.strip
            when /date/i
              hash[node.name.to_sym] = Time.parse(node.content.strip)
            else
              hash[node.name.to_sym] = node.content.strip
            end
          end
          hash
        end
        # @param [Array<XML::Node>] extensions Host extension data
        # @return [Hash]
        def info_host_extension(extension)
          {}
        end
    end
  end
end
