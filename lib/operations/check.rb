module NominetEPP
  module Operations
    module Check
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
    end
  end
end
