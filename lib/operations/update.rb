module NominetEPP
  module Operations
    # EPP Update Operation
    module Update
      # @param [Symbol] entity Entity to update
      # @param [String] id Domain, Account or Contact to update
      # @param [Hash] fields Fields to update
      def update(entity, id, fields = {})
        resp = @client.update do
          self.send(:"update_#{entity}", id, fields)
        end

        return resp.success?
      end
      private
        # Generate +domain:update+ payload
        # @param [String] name Domain name to update
        # @param [Hash] fields Fields to update on the domain
        # @return [XML::Node] +domain:update+ payload
        def update_domain(name, fields)
          domain('update') do |node, ns|
            node << XML::Node.new('name', name, ns)
            fields.each do |k,v|
              case k
              when :account
                node << (d_acct = XML::Node.new('account', nil, ns))
                d_acct << account('update') do |acct, a_ns|
                  account_update_xml(v, acct, a_ns)
                end
              when :ns
                node << domain_ns_xml(v, ns)
              else
                node << XML::Node.new(k.gsub('_', '-'), v, ns)
              end
            end
          end
        end

        # Generate +account:update+ payload
        # @param [String] roid Account ID
        # @param [Hash] fields Fields to update on the account
        # @return [XML::Node] +account:update+ payload
        def update_account(roid, fields = {})
          account('update') do |node, ns|
            node << XML::Node.new('roid', roid, ns)
            account_fields_xml(fields, node, ns)
          end
        end

        # Generate +contact:update+ payload
        # @param [String] roid Contact ID
        # @param [Hash] fields Fields to update on the contact
        # @raise [ArgumentError] invalid keys
        # @return [XML::Node] +contact:update+ payload
        def update_contact(roid, fields = {})
          raise ArgumentError, "fields allowed keys name, email, phone, mobile" unless (fields.keys - [:name, :email, :phone, :mobile]).empty?

          contact('update') do |node, ns|
            node << XML::Node.new('roid', roid, ns)
            fields.each do |k,v|
              node << XML::Node.new(k, v, ns)
            end
          end
        end
    end
  end
end
