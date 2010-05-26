module NominetEPP
  module Operations
    module Fork
      def fork(account_num, *names)
        resp = @client.update do
          account('fork') do |node, ns|
            node << XML::Node.new('roid', account_num, ns)
            names.each do |name|
              node << XML::Node.new('domain-name', name, ns)
            end
          end
        end

        return false unless resp.success?

        hash = {
          :roid => node_value(resp.data, '//account:creData/account:roid'),
          :name => node_value(resp.data, '//account:creData/account:name'),
          :crDate => node_value(resp.data, '//account:creData/account:crDate'),
          :contact => {
            :roid => node_value(resp.data, '//account:creData/account:contact/contact:creData/contact:roid'),
            :name => node_value(resp.data, '//account:creData/account:contact/contact:creData/contact:name')
          }
        }

        contact = resp.data.find('//account:creData/account:contact', namespaces).first
        hash[:contact][:type] = contact['type']
        hash[:contact][:order] = contact['order']

        hash
      end
    end
  end
end
