module NominetEPP
  module Operations
    # EPP Unrenew Operation
    module Unrenew
      # Reverse a renewal request for one or more domain names.
      #
      # Unrenew commands will only be processed if the renewal invoice
      # has not yet been generated. If the operation is successful, an
      # email will be sent to the registrant of the domain name notifying
      # them of the renewal reversal.
      #
      # @param [String, ...] names Domain names to unrenew
      # @return [false] unrenew failed
      # @return [Hash<String, Time>] hash of domains and expiry times 
      def unrenew(*names)
        @resp = @client.update do
          domain('unrenew') do |node, ns|
            names.each do |name|
              node << XML::Node.new('name', name, ns)
            end
          end
        end

        return false unless @resp.success?

        hash = {}
        @resp.data.find('//domain:renData', namespaces).each do |node|
          renName = node_value(node, 'domain:name')
          renExp  = node_value(node, 'domain:exDate')
          hash[renName] = Time.parse(renExp)
        end
        hash
      end
    end
  end
end
