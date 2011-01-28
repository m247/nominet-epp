module NominetEPP
  module Operations
    # EPP Transfer Operation
    module Transfer
      # @overload transfer(:release, name, tag, to_account_id = nil)
      #   @param [String] name Domain to release
      #   @param [String] tag TAG to release the domain to
      #   @param [String] to_account_id Specific account ID to release to
      #   @return [Hash] +{:result => true|:handshake}+ if successfully transferred or pending
      #   @return [false] transfer failed
      # @overload transfer(:approve, case_id)
      #   @param [String] case_id Transfer case to approve
      #   @return [false] failed
      #   @return [Hash] of +:case_id+ and array of +:domains+
      # @overload transfer(:reject, case_id)
      #   @param [String] case_id Transfer case to reject
      #   @return [false] failed
      #   @return [Hash] of +:case_id+ and array of +:domains+
      # @param [Symbol] type Type of transfer operation
      # @raise [ArgumentError] type is not one of +:release+, +:approve+ or +:reject+
      # @see transfer_release
      # @see transfer_approve
      # @see transfer_reject
      def transfer(type, *args)
        raise ArgumentError, "type must be :release, :approve, :reject" unless [:release, :approve, :reject].include?(type)

        @resp = @client.transfer do |transfer|
          transfer['op'] = type.to_s
          transfer << self.send(:"transfer_#{type}", *args)
        end

        if type == :release
          case @resp.code
          when 1000
            { :result => true }
          when 1001
            { :result => :handshake }
          else
            false
          end
        else
          return false unless @resp.success?
          nCase, domainList = @resp.data
          { :case_id => node_value(nCase,'//n:Case/n:case-id'),
            :domains => domainList.find('//n:domain-name', namespaces).map{|n| n.content.strip} }
        end
      end

      private
        # @param [String] name Domain to release
        # @param [String] tag TAG to release the domain to
        # @param [String] to_account_id Specific account ID to release to
        # @return [XML::Node] +domain:transfer+ payload 
        def transfer_release(name, tag, to_account_id = nil)
          domain('transfer') do |node, ns|
            node << XML::Node.new('name', name, ns)
            node << XML::Node.new('registrar-tag', tag, ns)

            unless to_account_id.nil?
              account = XML::Node.new('account', nil, ns)
              account << XML::Node.new('account-id', to_account_id, ns)
              node << account
            end
          end
        end

        # @param [String] case_id Transfer case to approve
        # @return [XML::Node] +notification:case+ payload
        def transfer_approve(case_id)
          notification('Case') do |node, ns|
            node << XML::Node.new('case-id', case_id, ns)
          end
        end

        # @param [String] case_id Transfer case to reject
        # @return [XML::Node] +notification:case+ payload
        def transfer_reject(case_id)
          notification('Case') do |node, ns|
            node << XML::Node.new('case-id', case_id, ns)
          end
        end
    end
  end
end
