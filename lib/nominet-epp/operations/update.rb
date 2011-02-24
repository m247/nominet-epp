module NominetEPP
  module Operations
    # EPP Update Operation
    module Update
      # @param [Symbol] entity Entity to update
      # @param [String] id Domain, Account or Contact to update
      # @param [Hash] fields Fields to update
      def update(entity, id, fields = {})
        @resp = @client.update do
          self.send(:"update_#{entity}", id, fields)
        end

        return @resp.success?
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

        # Generate +host:update+ payload to modify a nameserver entry
        # ---
        # We need to know nameserver old data as well.
        # If we are changing the nameserver name and keeping the info the same
        # then we do a host:chg. If we are adding an IPv{4,6} address we use
        # the host:add wrapper, and to remove we do a host:rem. As Nominet only
        # allow one IPv{4,6} address per nameserver we should remove the old
        # IP address from the server before adding the one. Alternatively if
        # Nominet will automatically drop previous address then we need only
        # do a host:add call.
        # +++
        #
        # Fields options
        # - (Hash) +:add+ -- Addresses to add to the nameserver
        # - (Hash) +:rem+ -- Addresses to remove from the nameserver
        # - (String) +:chg+ -- New hostname of the nameserver
        #
        # Fields +:add+ and +:rem+ options
        # - (String) +:v4+ -- IPv4 address to add or remove from the nameserver
        # - (String) +:v6+ -- IPv6 address to add or remove from the nameserver
        #
        # @param [String] name Nameserver host to update
        # @param [Hash] fields Nameserver update information
        # @raise [ArgumentError] invalid keys, either on fields or fields[:add] or fields[:rem]
        # @return [XML::Node] +host:update+ payload
        def update_nameserver(name, fields = {})
          raise ArgumentError, "allowed keys :add, :rem, :chg" unless (fields.keys - [:add, :rem, :chg]).empty?

          host('update') do |node, ns|
            node << XML::Node.new('name', name, ns)

            if fields.has_key?(:add) && fields[:add].kind_of?(Hash)
              raise ArgumentError, "allowed :add keys are :v4 and :v6" unless (fields[:add].keys - [:v4, :v6]).empty?
              node << (add = XML::Node.new('add', nil, ns))
              fields[:add].each do |k,v|
                add << (n = XML::Node.new('addr', v, ns))
                n['ip'] = k.to_s
              end
            end

            if fields.has_key?(:rem) && fields[:rem].kind_of?(Hash)
              raise ArgumentError, "allowed :rem keys are :v4 and :v6" unless (fields[:rem].keys - [:v4, :v6]).empty?
              node << (rem = XML::Node.new('rem', nil, ns))
              fields[:rem].each do |k,v|
                rem << (n = XML::Node.new('addr', v, ns))
                n['ip'] = k.to_s
              end
            end

            if fields.has_key?(:chg) && fields[:chg].kind_of?(String)
              node << (chg = XML::Node.new('chg', nil, ns))
              chg << XML::Node.new('name', fields[:chg], ns)
            end
          end
        end
    end
  end
end
