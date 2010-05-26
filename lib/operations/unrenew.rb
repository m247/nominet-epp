module NominetEPP
  module Operations
    module Unrenew
      def unrenew(*names)
        resp = @client.update do
          domain('unrenew') do |node, ns|
            names.each do |name|
              node << XML::Node.new('name', name, ns)
            end
          end
        end

        return false unless resp.success?

        hash = {}
        resp.data.find('//domain:renData', namespaces).each do |node|
          renName = node_value(node, 'domain:name')
          renExp  = node_value(node, 'domain:exDate')
          hash[renName] = Time.parse(renExp)
        end
        hash
      end
    end
  end
end
