module NominetEPP
  module Operations
    # == EPP Update Operation
    #
    # === Domain Update
    # The +id+ field for domain updates is the domain name to be modified.
    #
    # Fields options
    # - (Hash) +:account+ -- Hash of account details to be updated
    # - (String,Hash) +:ns+ -- Single or array of nameservers to set on the domain
    # - (String) +:first_bill+ -- Set first-bill
    # - (String) +:recur_bill+ -- Set recur-bill
    # - (String) +:auto_bill+ -- Set auto-bill
    # - (String) +:purchase_order+ -- Set purchase-oder
    # - (String) +:notes+ -- Notes about the domain
    # - (Boolean) +:renew_not_required+ -- Mark a domain as no longer needed
    # - (String) +:reseller+ -- Set reseller
    # ... etc ... any other permitted account fields
    #
    # === Account Update
    # The +id+ field for account updates is the ROID identifying
    # the account record on the remote endpoint.
    #
    # Fields options
    # - (Array) +:contacts+ -- Array of contacts to create on the account
    # - (Hash) +:addr+ -- Hash of address fields to modify on the account
    # - (String) +:name+ -- Account holder name
    # ... etc ... any other permitted account fields
    #
    # === Contact Update
    # The +id+ field for contact updates is the ROID identifying
    # the contact record on the remote endpoint.
    #
    # Fields options
    # - (String) +:name+ -- Contacts new name
    # - (String) +:email+ -- Contacts new email address
    # - (String) +:phone+ -- Contacts new phone number
    # - (String) +:mobile+ -- Contacts new mobile number
    #
    # === Nameserver Update
    # The +id+ field for nameserver updates is the fully qualified
    # hostname for the name server you wish to update.
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
    # Example:
    #
    #     fields = {:chg => 'new.ns.example.com',
    #               :add => {:v4 => '192.168.1.45', :v6 => '2001:db8::1'},
    #               :rem => {:v4 => '192.168.1.14', :v6 => '2001:db8::b'}}
    #
    module Update
      # @param [Symbol] entity Entity to update, one of domain, account, contact or nameserver
      # @param [String] id Domain, Account, Contact or Nameserver to update
      # @param [Hash] fields Fields to update
      # @return [Boolean] request successful
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
          keys = [:auto_period, :account, :ns, :first_bill, :recur_bill,
            :auto_bill, :next_bill, :renew_not_required, :notes, :reseller]

          domain('update') do |node, ns|
            node << XML::Node.new('name', name, ns)
            keys.each do |k|
              next if fields[k].nil?
              case k
              when :account
                node << (d_acct = XML::Node.new('account', nil, ns))
                d_acct << account('update') do |acct, a_ns|
                  account_update_xml(fields[k], acct, a_ns)
                end
              when :ns
                node << domain_ns_xml(fields[k], ns)
              else
                node << generic_field_to_xml(k, fields[k], ns) unless fields[k] == ''
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
        # @return [XML::Node] XML +contact:update+ element
        def update_contact(roid, fields = {})
          contact_to_xml(fields.merge(:roid => roid))
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
