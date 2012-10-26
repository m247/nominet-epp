module NominetEPP
  module Operations
    # EPP Handshake Operations
    module Handshake
      def handshake(action, case_id, registrant = nil)
        raise ArgumentError, "action must be one of :accept or :reject" unless [:accept, :reject].include?(entity)

        resp = @client.update do
          handshake(action) do |node, ns|
            node << XML::Node.new('caseId', case_id, ns)
            if action == :accept && registrant
              node << XML::Node.new('registrant', registrant, ns)
            end
          end
        end

        return false unless resp.success?

        resp.data.find('//std-handshake:hanData', namespaces).first.children.reject{|n| n.empty?}.each do |node|
          return node.find('//std-handshake:domainName', namespaces).map do |domainName|
            domainName.content.strip
          end
        end

        [] # no idea what we'd get if we don't have h:domainListData/h:domainName
      end
    end
  end
end
