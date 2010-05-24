module NominetEPP
  module Operations
    module Info
      def info(entity, id)
        raise ArgumentError, "entity must be :domain, :contact or :account" unless [:domain, :contact, :account].include?(entity)

        resp = @client.info do
          case entity
          when :domain
            domain('info') { |node, ns| node << XML::Node.new('name', id, ns) }
          when :account
            account('info') { |node, ns| node << XML::Node.new('roid', id, ns) }
          when :contact
            contact('info') { |node, ns| node << XML::Node.new('roid', id, ns) }
          end
        end

        return false unless resp.success?
        self.send(:"info_#{entity}", resp.data)
      end

      private
        def info_domain(data)
          hash = {}
          data.find('domain:infData').first.children.reject(&:empty?).each do |node|
            key = node.name.gsub('-', '_').to_sym
            case node.name
            when 'account'
              hash[:account] = info_account(node)
            when 'ns'
              hash[:ns] = node.find('domain:host').map do |hostnode|
                { :name => node_value(hostnode, 'domain:hostName'),
                  :v4 => node_value(hostnode, 'domain:hostAddr[@ip="v4"]'),
                  :v6 => node_value(hostnode, 'domain:hostAddr[@ip="v6"]') }.reject{|k,v| v.nil?}
              end
            when /date/i
              hash[key] = Time.parse(node.content.strip)
            else
              hash[key] = node.content.strip
            end
          end
          hash
        end
        def info_account(data)
          hash = {}
          data.find('account:infData').first.children.reject(&:empty?).each do |node|
            key = node.name.gsub('-', '_').to_sym
            case node.name
            when 'addr'
              hash[:addr] = {}
              node.children.reject(&:empty?).each do |n|
                hash[:addr][n.name.to_sym] = node.content.strip
              end
            when 'contact'
              hash[:contacts] ||= Array.new
              hash[:contacts] << info_contact(node)
              hash[:contacts].last[:type] = node['type']
              hash[:contacts].last[:order] = node['order']
            when /date/i
              hash[key] = Time.parse(node.content.strip)
            else
              hash[key] = node.content.strip
            end
          end
          hash
        end
        def info_contact(data)
          hash = {}
          data.find('contact:infData').first.children.reject(&:empty?).each do |node|
            if node.name =~ /date/i
              hash[node.name.to_sym] = Time.parse(node.content.strip)
            else
              hash[node.name.to_sym] = node.content.strip
            end
          end
          hash
        end
        def info_addr(node)
          data
        end
    end
  end
end
