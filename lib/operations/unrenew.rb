module NominetEPP
  module Operations
    module Unrenew
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
    end
  end
end
