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
          :roid => resp.data.find('//account:creData/account:roid').first.content.strip,
          :name => resp.data.find('//account:creData/account:name').first.content.strip,
          :crDate => resp.data.find('//account:creData/account:crDate').first.content.strip,
          :contact => {
            :roid => resp.data.find('//account:creData/account:contact/contact:creData/contact:roid').first.content.strip,
            :name => resp.data.find('//account:creData/account:contact/contact:creData/contact:name').first.content.strip
          }
        }

        contact = resp.data.find('//account:creData/account:contact').first
        hash[:contact][:type] = contact['type']
        hash[:contact][:order] = contact['order']

        hash
      end
    end
  end
end
