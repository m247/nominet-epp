module NominetEPP
  module Operations
    module Transfer
      def transfer(type, *args)
        raise ArgumentError, "type must be :release, :approve, :reject" unless [:release, :approve, :reject].include?(type)

        resp = @client.transfer do |transfer|
          transfer['op'] = type.to_s
          transfer << self.send(:"transfer_#{type}", *args)
        end

        if type == :release
          case resp.code
          when 1000
            { :result => true }
          when 1001
            { :result => :handshake }
          else
            false
          end
        else
          return false unless resp.success?
          nCase, domainList = resp.data
          { :case_id => node_value(nCase,'//n:Case/n:case-id'),
            :domains => domainList.find('//n:domain-name', namespaces).map{|n| n.content.strip} }
        end
      end

      private
        def transfer_release(name, tag, to_account_id = nil)
          domain('transfer') do |node, ns|
            node << XML::Node.new('name', domain, ns)
            node << XML::Node.new('registrar-tag', tag, ns)

            unless to_account_id.nil?
              account = XML::Node.new('account', nil, ns)
              account << XML::Node.new('account-id', to_account_id, ns)
              node << account
            end
          end
        end
        def transfer_approve(case_id)
          notification('Case') do |node, ns|
            node << XML::Node.new('case-id', case_id, ns)
          end
        end
        def transfer_reject(case_id)
          notification('Case') do |node, ns|
            node << XML::Node.new('case-id', case_id, ns)
          end
        end
    end
  end
end
