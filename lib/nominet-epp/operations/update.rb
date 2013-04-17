module NominetEPP
  module Operations
    # == EPP Update Operation
    #
    # === Domain Update
    # The +id+ field for domain updates is the domain name to be modified.
    #
    # ==== Changes +:add+ and +:rem+ options
    # - (Array<String>)         +:ns+          -- Nameservers to add or remove from the domain
    # - (Hash<Symbol,String>)   +:contact+     -- Contacts to add/remove in +{:type => "id"}+ pairs
    #
    # ==== Changes +:add+ options
    # - (Hash<Symbol,String>)   +:status+      -- Adds the symbolised status with the given message to the domain
    # - (Array<Hash>)           +:ds+          -- DNSSEC DS records to add, +:key_tag+, +:alg+, +:digest_type+ & +:digest+ required
    #
    # ==== Changes +:rem+ options
    # - (String,Array<String>)  +:status+      -- Removes the given status from the domain
    # - (Array<Hash>,Symbol)    +:ds+          -- DNSSEC DS records to remove, or +:all+ to remove all records.
    #
    # ==== Changes +:chg+ options
    # - (String)                +:registrant+  -- Registrant ID
    # - (String)                +:auth_info+   -- ignored
    #
    # ==== Nominet Extension Keys
    # Extension keys can be included in either the +:add+ or +:chg+ keys.
    #
    # - (String)                +:first_bill+  -- Set first-bill
    # - (String)                +:recur_bill+  -- Set recur-bill
    # - (String)                +:auto_bill+   -- Set auto-bill
    # - (String,Array<String>)  +:notes+       -- Notes about the domain
    # - (Boolean)               +:renew_not_required+ -- Mark a domain as no longer needed
    # - (String)                +:reseller+    -- Set reseller
    #
    # === Contact Update
    # The +id+ field for contact updates is the ID identifying
    # the contact record on the remote endpoint.
    #
    # ==== Changes +:add+ options
    # - (Hash<Symbol,String>)   +:status+      -- Adds the symbolised status with the given message to the contact
    #
    # ==== Changes +:rem+ options
    # - (String,Array<String>)  +:status+      -- Removes the given status from the contact
    #
    # ==== Changes +:chg+ options
    # - (String)                +:auth_info+   -- ignored
    # - (Array<String>)         +:disclose+    -- Array of fields, eg "voice, email"
    # - (String)                +:voice+       -- Voice telephone number
    # - (String)                +:fax+         -- Fax telephone number
    # - (String)                +:email+       -- Email address
    # - (Hash)                  +:postal_info+ -- Postal Information
    #
    # ==== Postal Information fields
    # - (String)                +:name+        -- Name of the contact
    # - (String)                +:org+         -- Name of the organisation
    # - (Hash)                  +:addr+        -- Postal Address Details
    #
    # ==== Postal Information Addr fields
    # - (String,Array<String>)  +:street+      -- Street name(s)
    # - (String)                +:city+        -- City
    # - (String)                +:sp+          -- State/Province
    # - (String)                +:pc+          -- Postal Code
    # - (String)                +:cc+          -- Country Code
    #
    # ==== Nominet Extension Keys
    # Extension keys can be included in either the +:add+ or +:chg+ keys.
    #
    # - (String)                +:trad_name+   -- Company trading name
    # - (String)                +:type+        -- Nominet registrant type
    # - (String)                +:co_no+       -- Company registration number
    # - (Boolean)               +:opt_out+     -- WHOIS opt out
    #
    # === Nameserver Update
    # The +id+ field for nameserver updates is the fully qualified
    # hostname for the name server you wish to update.
    #
    # ==== Changes +:add+ and +:rem+ options
    # - (String) +:v4+ -- IPv4 address to add or remove from the nameserver
    # - (String) +:v6+ -- IPv6 address to add or remove from the nameserver
    #
    # ==== Changes +:chg+ options
    # - (String) New hostname of the nameserver
    #
    # ==== Example:
    #
    #     fields = {:chg => 'new.ns.example.com',
    #               :add => {:v4 => '192.168.1.45', :v6 => '2001:db8::1'},
    #               :rem => {:v4 => '192.168.1.14', :v6 => '2001:db8::b'}}
    #
    module Update
      # List of update keys for domains which are sent on the <epp:extension> element
      # @internal These must be kept in the order defined by the XML Schema
      DOMAIN_EXTENSION_KEYS = [:first_bill, :recur_bill, :auto_bill, :next_bill, :auto_period, :next_period, :renew_not_required, :notes, :reseller]

      # List of update keys for contacts which are sent on the <epp:extension> element
      # @internal These must be kept in the order defined by the XML Schema
      CONTACT_EXTENSION_KEYS = [:trad_name, :type, :co_no, :opt_out]

      # @param [Symbol] entity Type of entity to update, :domain, :contact, :nameserver/:host
      # @param [String] id Entity identifier
      # @param [Hash] changes Hash of :add, :rem, :chg changes.
      # @option changes [Hash] :add Hash of fields to add to the entity
      # @option changes [Hash] :rem Hash of fields to remove from the entity
      # @option changes [Hash] :chg Hash of fields to update on the entity
      # @return [Boolean] whether the update succeeded or failed
      def update(entity, id, changes = {})
        update_method = :"update_#{entity}"

        raise ArgumentError, "entity #{entity} is not supported" unless self.respond_to?(update_method, true)
        raise ArgumentError, "allowed changes are :add, :rem, :chg" unless (changes.keys - [:add, :rem, :chg]).empty?
        raise ArgumentError, "changes[:add] must be a hash" unless changes[:add].nil? || changes[:add].kind_of?(Hash)
        raise ArgumentError, "changes[:rem] must be a hash" unless changes[:rem].nil? || changes[:rem].kind_of?(Hash)
        raise ArgumentError, "changes[:chg] must be a hash" unless changes[:chg].nil? || changes[:chg].kind_of?(Hash)

        instrument :update, :entity => entity, :id => id do
          resp = instrument 'update.request', :entity => entity do
            @client.update do |update, extension|
              self.send(update_method, update, extension, id, changes)
            end
          end

          resp.success?
        end
      end

      private
        # @param [XML::Node] update The <epp:update> XML Node
        # @param [XML::Node] extension The <epp:extension> XML Node
        # @param [String] name Domain name identifier
        # @param [Hash] changes Changes to apply to the domain
        def update_domain(update, extension, name, changes)
          extensions = (changes[:add] || {}).merge(changes[:chg] || {})
          extensions.delete_if { |k,_| !DOMAIN_EXTENSION_KEYS.include?(k) }

          changes[:add] && changes[:add].delete_if { |k,_| DOMAIN_EXTENSION_KEYS.include?(k) }
          changes[:rem] && changes[:rem].delete_if { |k,_| DOMAIN_EXTENSION_KEYS.include?(k) }
          changes[:chg] && changes[:chg].delete_if { |k,_| DOMAIN_EXTENSION_KEYS.include?(k) }

          dnssec = {}
          dnssec[:add] = changes[:add] && changes[:add].delete(:ds)
          dnssec[:rem] = changes[:rem] && changes[:rem].delete(:ds)
          dnssec[:chg] = changes[:chg] && changes[:chg].delete(:ds)

          addrem_order = [:ns, :contact, :status]

          update << domain('update') do |node, ns|
            node << XML::Node.new('name', name, ns)

            if changes[:add] && !changes[:add].empty?
              node << XML::Node.new('add', nil, ns).tap do |add|
                addrem_order.each do |key|
                  value = changes[:add][key]
                  next if value.nil?

                  update_domain_addrem(add, key, value, ns)
                end
              end
            end

            if changes[:rem] && !changes[:rem].empty?
              node << XML::Node.new('rem', nil, ns).tap do |rem|
                addrem_order.each do |key|
                  value = changes[:rem][key]
                  next if value.nil?

                  update_domain_addrem(rem, key, value, ns)
                end
              end
            end

            if changes[:chg] && !changes[:chg].empty?
              node << XML::Node.new('chg', nil, ns).tap do |chg|
                [:registrant, :auth_info].each do |key|
                  value = changes[:chg][key]
                  next if value.nil?

                  case key
                  when :registrant
                    chg << XML::Node.new('registrant', value, ns)
                  when :auth_info
                    # ignored, Nominet does not support this
                  end
                end
              end
            end
          end

          unless extensions.empty?
            extension << domain_ext('update') do |node, ns|
              DOMAIN_EXTENSION_KEYS.each do |key|
                value = extensions[key]
                next if value.nil?

                case key
                when :notes
                  Array(value).each do |note|
                    node << XML::Node.new('notes', note, ns)
                  end
                when :renew_not_required
                  node << XML::Node.new('renew-not-required', value ? 'Y' : 'N', ns)
                else
                  name = key.to_s.gsub('_','-')
                  node << XML::Node.new(name, value, ns)
                end
              end
            end
          end

          unless dnssec.empty?
            extension << secdns('update') do |node, ns|
              if dnssec[:rem]
                case dnssec[:rem]
                when :all
                  node << XML::Node.new('rem', nil, ns).tap do |n|
                    n << XML::Node.new('all', 'true', ns)
                  end
                when Hash
                  unless dnssec[:rem].empty?
                    node << XML::Node.new('rem', nil, ns).tap do |n|
                      dnssec[:rem].each do |ds|
                        n << XML::Node.new('dsData', nil, ns).tap do |dsData|
                          dsData << XML::Node.new('keyTag', ds[:key_tag], ns)
                          dsData << XML::Node.new('alg', ds[:alg], ns)
                          dsData << XML::Node.new('digestType', ds[:digest_type], ns)
                          dsData << XML::Node.new('digest', ds[:digest], ns)
                        end
                      end
                    end
                  end
                end
              end

              if dnssec[:add] && !dnssec[:add].empty?
                node << XML::Node.new('add', nil, ns).tap do |n|
                  dnssec[:add].each do |ds|
                    n << XML::Node.new('dsData', nil, ns).tap do |dsData|
                      dsData << XML::Node.new('keyTag', ds[:key_tag], ns)
                      dsData << XML::Node.new('alg', ds[:alg], ns)
                      dsData << XML::Node.new('digestType', ds[:digest_type], ns)
                      dsData << XML::Node.new('digest', ds[:digest], ns)
                    end
                  end
                end
              end

              if dnssec[:chg] && !dnssec[:chg].empty?
                # Nominet don't support maxSigLife so nothing happens here
              end
            end
          end
        end

        # @example
        #     :ns => %w(ns1 ns2 ns3 ns4)
        #     :contact => {:tech => 'tech1'}
        #     :status => {:ok => 'message', :clientUpdateProhibited => 'client unpaid'} or [:ok]
        #
        # @param [XML::Node] node XML Node to add data to
        # @param [Symbol] key Key to add to the +node+
        # @param [Object] value Value of the key to add to +node+
        # @param [XML::Namespace] ns XML Namespace to create new nodes under
        def update_domain_addrem(node, key, value, ns)
          case key
          when :ns
            node << XML::Node.new('ns', nil, ns).tap do |n|
              Array(value).each do |nameserver|
                n << XML::Node.new('hostObj', nameserver, ns)
              end
            end
          when :contact
            value.each do |type, id|
              node << XML::Node.new('contact', id, ns).tap do |n|
                n['type'] = type.to_s
              end
            end
          when :status
            case value
            when Array
              value.each do |status|
                node << XML::Node.new('status', nil, ns).tap do |n|
                  n["s"] = status.to_s
                end
              end
            when Hash
              value.each do |status, message|
                node << XML::Node.new('status', message, ns).tap do |n|
                  n["s"] = status.to_s
                end
              end
            end
          else
            return # unsupported key
          end
        end

        # @param [XML::Node] update The <epp:update> XML Node
        # @param [XML::Node] extension The <epp:extension> XML Node
        # @param [String] id Contact identifier
        # @param [Hash] changes Changes to apply to the contact
        def update_contact(update, extension, id, changes)
          extensions = (changes[:add] || {}).merge(changes[:chg] || {})
          extensions.delete_if { |k,_| !CONTACT_EXTENSION_KEYS.include?(k) }

          changes[:add] && changes[:add].delete_if { |k,_| CONTACT_EXTENSION_KEYS.include?(k) }
          changes[:rem] && changes[:rem].delete_if { |k,_| CONTACT_EXTENSION_KEYS.include?(k) }
          changes[:chg] && changes[:chg].delete_if { |k,_| CONTACT_EXTENSION_KEYS.include?(k) }

          addrem_order = [:status]

          update << contact('update') do |node, ns|
            node << XML::Node.new('id', id, ns)

            if changes[:add] && !changes[:add].empty?
              node << XML::Node.new('add', nil, ns).tap do |add|
                addrem_order.each do |key|
                  value = changes[:add][key]
                  next if value.nil?

                  update_contact_addrem(add, key, value, ns)
                end
              end
            end

            if changes[:rem] && !changes[:rem].empty?
              node << XML::Node.new('rem', nil, ns).tap do |rem|
                addrem_order.each do |key|
                  value = changes[:rem][key]
                  next if value.nil?

                  update_contact_addrem(rem, key, value, ns)
                end
              end
            end

            if changes[:chg] && !changes[:chg].empty?
              node << XML::Node.new('chg', nil, ns).tap do |chg|
                [:postal_info, :voice, :fax, :email, :auth_info, :disclose].each do |key|
                  value = changes[:chg][key]
                  next if value.nil?

                  case key
                  when :postal_info
                    chg << XML::Node.new('postalInfo', nil, ns).tap do |post|
                      post['type'] = 'loc'
                      update_contact_postal_info(post, value, ns)
                    end
                  when :disclose
                    chg << XML::Node.new('disclose', nil, ns).tap do |d|
                      d["flag"] = "1"
                      Array(value).each do |v|
                        d << XML::Node.new(v, nil, ns)
                      end
                    end
                  when :auth_info
                    # ignored, Nominet does not support this
                  else
                    # voice, fax, email
                    name = key.to_s.gsub('_', '-')
                    chg << XML::Node.new(name, value, ns)
                  end
                end
              end
            end
          end

          unless extensions.empty?
            extension << contact_ext('update') do |node, ns|
              CONTACT_EXTENSION_KEYS.each do |key|
                value = extensions[key]
                next if value.nil?

                case key
                when :opt_out
                  node << XML::Node.new('opt-out', value ? 'Y' : 'N', ns)
                else
                  name = key.to_s.gsub('_','-')
                  node << XML::Node.new(name, value, ns)
                end
              end
            end
          end
        end

        # @example
        #     :status => {:ok => 'message', :clientUpdateProhibited => 'client unpaid'} or [:ok]
        #
        # @param [XML::Node] node XML Node to add data to
        # @param [Symbol] key Key to add to the +node+
        # @param [Object] value Value of the key to add to +node+
        # @param [XML::Namespace] ns XML Namespace to create new nodes under
        def update_contact_addrem(node, key, value, ns)
          case key
          when :status
            case value
            when Array
              # We could raise an argument error if trying to do this on an Add
              # as we can check the node.name to make sure its "rem" not "add".
              value.each do |status|
                node << XML::Node.new('status', nil, ns).tap do |n|
                  n["s"] = status.to_s
                end
              end
            when Hash
              value.each do |status, message|
                node << XML::Node.new('status', message, ns).tap do |n|
                  n["s"] = status.to_s
                end
              end
            end
          else
            return # unsupported key
          end
        end

        # @param [XML::Node] node XML Node to add data to
        # @param [Hash] data Information to add to +node+
        # @param [XML::Namespace] ns XML Namespace to create new nodes under
        def update_contact_postal_info(node, data, ns)
          [:name, :addr].each do |key|
            value = data[key]
            next if value.nil?

            case key
            when :addr
              node << XML::Node.new('addr', nil, ns).tap do |n|
                [:street, :city, :sp, :pc, :cc].each do |k|
                  v = value[k]
                  next if v.nil?

                  case v
                  when Array
                    v.each do |i|
                      n << XML::Node.new(k, i, ns)
                    end
                  else
                    n << XML::Node.new(k, v, ns)
                  end
                end
              end
            when :name, :org
              name = key.to_s.gsub('_','-')
              node << XML::Node.new(name, value, ns)
            end
          end
        end

        # Generate +host:update+ payload to modify a nameserver entry
        #
        # @internal
        #   We need to know nameserver old data as well.
        #   If we are changing the nameserver name and keeping the info the same
        #   then we do a host:chg. If we are adding an IPv{4,6} address we use
        #   the host:add wrapper, and to remove we do a host:rem. As Nominet only
        #   allow one IPv{4,6} address per nameserver we should remove the old
        #   IP address from the server before adding the one. Alternatively if
        #   Nominet will automatically drop previous address then we need only
        #   do a host:add call.
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
        # @param [XML::Node] update The <epp:update> XML Node
        # @param [XML::Node] extension The <epp:extension> XML Node
        # @param [String] name Nameserver host to update
        # @param [Hash] changes Nameserver update information
        # @raise [ArgumentError] invalid keys, either on changes or changes[:add] or changes[:rem]
        def update_nameserver(update, extension, name, changes)
          update << host('update') do |node, ns|
            node << XML::Node.new('name', name, ns)

            if changes.has_key?(:add) && changes[:add].kind_of?(Hash)
              raise ArgumentError, "allowed :add keys are :v4 and :v6" unless (changes[:add].keys - [:v4, :v6]).empty?
              node << (add = XML::Node.new('add', nil, ns))
              changes[:add].each do |k,v|
                add << (n = XML::Node.new('addr', v, ns))
                n['ip'] = k.to_s
              end
            end

            if changes.has_key?(:rem) && changes[:rem].kind_of?(Hash)
              raise ArgumentError, "allowed :rem keys are :v4 and :v6" unless (changes[:rem].keys - [:v4, :v6]).empty?
              node << (rem = XML::Node.new('rem', nil, ns))
              changes[:rem].each do |k,v|
                rem << (n = XML::Node.new('addr', v, ns))
                n['ip'] = k.to_s
              end
            end

            if changes.has_key?(:chg) && changes[:chg].kind_of?(String)
              node << (chg = XML::Node.new('chg', nil, ns))
              chg << XML::Node.new('name', changes[:chg], ns)
            end
          end
        end
        alias update_host update_nameserver
    end
  end
end
