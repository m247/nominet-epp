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
      # @param [String] acct
      # @param [Array] nameservers Nameservers to set for the domain
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

            options[:period] && node << XML::Node.new('period', options.delete(:period), ns)

            acct_xml = XML::Node.new('account', nil, ns)
            acct_xml << create_account(acct, ns)
            node << acct_xml

            node << domain_ns_xml(nameservers, ns)

            options.each do |key, value|
              node << XML::Node.new(key.to_s.gsub('_', '-'), value, ns)
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
              node << XML::Node.new('trad-name', acct[:trad_name], ns)
              node << XML::Node.new('type', acct[:type], ns)
              node << XML::Node.new('opt-out', acct[:opt_out], ns)

              acct[:contacts].each_with_index do |cont, i|
                c = XML::Node.new('contact', nil, ns)
                c['order'] = i
                node << (c << create_account_contact(cont))
              end

              node << create_account_address(acct[:addr], ns)
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
            cont.each do |key, value|
              node << XML::Node.new(key, value, ns)
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

          addr = XML::Node.new('addr', nil, ns)
          addr.each do |key, value|
            addr << XML::Node.new(key, value, ns)
          end

          addr
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
