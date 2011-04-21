module NominetEPP
  module Operations
    # EPP Create Operation
    module Create
      # Register a domain name with Nominet.
      #
      # The returned hash has the following keys
      # - (String) +:name+ --    Domain name registered
      # - (Time) +:crDate+ --    Domain creation date
      # - (Time) +:exDate+ --    Domain expiration date
      # - (Hash) +:account+ --   Created account data (if returned)
      #
      # The +:account+ hash contains the following keys
      # - (String) +:roid+ --    Account ID
      # - (String) +:name+ --    Account Name
      # - (Array) +:contacts+ -- Account contacts
      #
      # The +:contacts+ array contains hashes of the following keys
      # - (String) +:roid+ --    Contact ID
      # - (String) +:name+ --    Contact Name
      # - (String) +:type+ --    Contact type if set
      # - (Integer) +:order+ --  Contacts order in the list of contacts
      #
      # @param [String] name Domain name to register
      # @param [String, Hash] acct
      # @param [String, Array] nameservers Nameservers to set for the domain
      # @param [Hash] options Registration options
      # @option options [String] :period
      # @option options [String] :first_bill
      # @option options [String] :recur_bill
      # @option options [String] :auto_bill
      # @option options [String] :next_bill
      # @option options [String] :notes
      # @raise [ArgumentError] invalid option keys
      # @return [false] registration failed
      # @return [Hash] Domain creation data
      def create(name, acct, nameservers, options = {})
        raise ArgumentError, "options allowed keys are period, first_bill, recur_bill, auto_bill, next_bill, notes" unless (options.keys - [:period, :first_bill, :recur_bill, :auto_bill, :next_bill, :notes]).empty?

        @resp = @client.create do
          domain('create') do |node, ns|
            node << XML::Node.new('name', name, ns)

            if period = options.delete(:period)
              unit = period[-1..1]
              num = period.to_i.to_s
              p = XML::Node.new('period', num, ns);
              p['unit'] = unit
              node << p
            end

            # node << XML::Node.new('auto-period', '', ns) # placeholder

            node << XML::Node.new('account', nil, ns).tap do |acct_xml|
              acct_xml << create_account(acct, ns)
            end

            node << domain_ns_xml(nameservers, ns)

            # Enforce correct sequencing of option fields
            [:first_bill, :recur_bill, :auto_bill, :next_bill, :notes].each do |key|
              next if options[key].nil? || options[key] == ''
              node << XML::Node.new(key.to_s.gsub('_', '-'), options[key], ns)
            end
          end
        end

        return false unless @resp.success?

        creData = @resp.data.find('//domain:creData', namespaces).first
        h = { :name => node_value(creData, 'domain:name'),
          :crDate => Time.parse(node_value(creData, 'domain:crDate')),
          :exDate => Time.parse(node_value(creData, 'domain:exDate')) }
        unless creData.find('domain:account').first.nil?
          h[:account] = created_account(creData.find('domain:account/account:creData', namespaces).first)
        end
        h
      end
      
      private
        # Create the account payload
        #
        # @param [String, Hash] acct Account ID or New account fields
        # @param [XML::Namespace] domain_ns +:domain+ namespace
        # @raise [ArgumentError] acct must be a String or a Hash of account fields
        # @return [XML::Node]
        def create_account(acct, domain_ns)
          if acct.kind_of?(String)
            XML::Node.new('account-id', acct, domain_ns)
          elsif acct.kind_of?(Hash)
            account('create') do |node, ns|
              node << XML::Node.new('name', acct[:name], ns)
              node << XML::Node.new('trad-name', acct[:trad_name], ns) unless acct[:trad_name].nil? || acct[:trad_name] == ''
              node << XML::Node.new('type', acct[:type], ns)
              node << XML::Node.new('co-no', acct[:co_no], ns) unless acct[:co_no].nil? || acct[:co_no] == ''
              node << XML::Node.new('opt-out', acct[:opt_out], ns)

              node << create_account_address(acct[:addr], ns) unless acct[:addr].nil?

              acct[:contacts].each_with_index do |cont, i|
                c = XML::Node.new('contact', nil, ns)
                c['order'] = i.to_s
                node << (c << create_account_contact(cont))
              end
            end
          else
            raise ArgumentError, "acct must be String or Hash"
          end
        end

        # Create account contact payload
        #
        # @param [Hash] cont Contact fields
        # @raise [ArgumentError] invalid contact fields
        # @raise [ArgumentError] name or email key is missing
        # @return [XML::Node]
        def create_account_contact(cont)
          raise ArgumentError, "cont must be a hash" unless cont.is_a?(Hash)
          raise ArgumentError, "Contact allowed keys are name, email, phone and mobile" unless (cont.keys - [:name, :email, :phone, :mobile]).empty?
          raise ArgumentError, "Contact requires name and email keys" unless cont.has_key?(:name) && cont.has_key?(:email)

          contact('create') do |node, ns|
            [:name, :phone, :mobile, :email].each do |key|
              next if cont[key].nil? || cont[key] == ''
              node << XML::Node.new(key, cont[key], ns)
            end
          end
        end

        # Create contact address
        #
        # @param [Hash] addr Address fields
        # @param [XML::Namespace] ns XML Namespace
        # @raise [ArgumentError] invalid keys in addr
        # @return [XML::Node]
        def create_account_address(addr, ns)
          raise ArgumentError, "addr must be a hash" unless addr.is_a?(Hash)
          raise ArgumentError, "ns must be an xml namespace" unless ns.is_a?(XML::Namespace)
          raise ArgumentError, "Address allowed keys are street, locality, city, county, postcode, country" unless (addr.keys - [:street, :locality, :city, :county, :postcode, :country]).empty?

          XML::Node.new('addr', nil, ns).tap do |a|
            [:street, :locality, :city, :county, :postcode, :country].each do |key|
              next if addr[key].nil? || addr[key] == ''
              a << XML::Node.new(key, addr[key], ns)
            end
          end
        end

        # Collects created account information
        #
        # @param [XML::Node] creData XML
        # @return [Hash]
        def created_account(creData)
          { :roid => node_value(creData, 'account:roid'),
            :name => node_value(creData, 'account:name'),
            :contacts => created_contacts(creData.find(
              'account:contact', namespaces)) }
        end

        # Collects created account contacts
        #
        # @param [XML::Node] account_contacts Account contacts
        # @return [Hash]
        def created_contacts(account_contacts)
          account_contacts.map do |cont|
            { :type => cont['type'],
              :order => cont['order'] }.merge(
                created_contact(cont.find('contact:creData', namespaces).first))
          end
        end

        # Collects create contact information
        #
        # @param [XML::Node] creData XML
        # @return [Hash]
        def created_contact(creData)
          { :roid => node_value(creData, 'contact:roid'),
            :name => node_value(creData, 'contact:name') }
        end
    end
  end
end
