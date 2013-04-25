require 'securerandom'
module NominetEPP
  module Operations
    # EPP Create Operation
    module Create
      # List of update keys for domains which are sent on the <epp:extension> element
      # @internal These must be kept in the order defined by the XML Schema
      DOMAIN_EXTENSION_KEYS = [:first_bill, :recur_bill, :auto_bill, :next_bill, :auto_period, :next_period, :notes, :reseller]

      # List of update keys for contacts which are sent on the <epp:extension> element
      # @internal These must be kept in the order defined by the XML Schema
      CONTACT_EXTENSION_KEYS = [:trad_name, :type, :co_no, :opt_out]

      # @param [Symbol] entity Type of object to create
      # @param [String] name Name of the object to create
      # @param [Hash] options Options/attributes of the entity to create
      def create(entity, name, options = {})
        create_method = :"create_#{entity}"

        raise ArgumentError, "entity #{entity} is not supported" unless self.respond_to?(create_method, true)

        instrument :create, :entity => entity, :name => name do
          resp = instrument 'create.request', :entity => entity do
            @client.create do |create, extension|
              self.send(create_method, create, extension, name, options)
            end
          end

          if resp.success?
            return instrument('create.parse', :entity => entity) do
              self.send(:"create_#{entity}_response", resp)
            end
          end

          # Capture error information
          @error_info = { :name => resp.message, :reason => resp.error_reason }
          return false
        end
      end

      private
        # :name, :period, :ns, :registrant
        #
        # Nominet declined
        #  :contact
        # Nominet ignored
        #  :authInfo (EPP required, so SecureRandom.hex(8) if missing)
        # 
        def create_domain(create, extension, name, options)
          extensions = options.dup
          extensions.delete_if { |k,_| !DOMAIN_EXTENSION_KEYS.include?(k) }
          options.delete_if { |k,_| DOMAIN_EXTENSION_KEYS.include?(k) }

          dnssec = options.delete(:ds)

          create << domain('create') do |node, ns|
            node << XML::Node.new('name', name, ns)

            options[:auth_info] ||= options.delete(:authInfo) || SecureRandom.hex(8).upcase
            options.delete(:authInfo) # Make sure its not present

            # Sequence of elements must be in this order
            [:period, :ns, :registrant, :contact, :auth_info].each do |key|
              value = options[key]
              next if value.nil?

              case key
              when :period
                unit, period = value[-1,1], value.to_i.to_s
                node << XML::Node.new('period', period, ns).tap do |n|
                  n['unit'] = unit
                end
              when :ns
                node << XML::Node.new('ns', nil, ns).tap do |n|
                  value.each do |nameserver|
                    n << XML::Node.new('hostObj', nameserver, ns)
                  end
                end
              when :registrant
                node << XML::Node.new('registrant', value, ns)
              when :auth_info
                node << XML::Node.new('authInfo', nil, ns).tap do |n|
                  n << XML::Node.new('pw', value, ns)
                end
              end
            end
          end

          unless extensions.empty?
            extension << domain_ext('create') do |node, ns|
              DOMAIN_EXTENSION_KEYS.each do |key|
                value = extensions[key]
                next if value.nil?

                case key
                when :notes
                  Array(value).each do |note|
                    node << XML::Node.new('notes', note, ns)
                  end
                else
                  name = key.to_s.gsub('_','-')
                  node << XML::Node.new(name, value, ns)
                end
              end
            end
          end

          unless dnssec.nil?
            extension << secdns('create') do |node, ns|
              Array(dnssec).each do |ds|
                node << XML::Node.new('dsData', nil, ns).tap do |n|
                  n << XML::Node.new('keyTag', ds[:key_tag], ns)
                  n << XML::Node.new('alg', ds[:alg], ns)
                  n << XML::Node.new('digestType', ds[:digest_type], ns)
                  n << XML::Node.new('digest', ds[:digest], ns)
                end
              end
            end
          end
        end

        def create_domain_response(resp)
          creData = resp.data.find('//domain:creData', namespaces).first
          { :name => node_value(creData, 'domain:name'),
            :crDate => Time.parse(node_value(creData, 'domain:crDate')),
            :exDate => Time.parse(node_value(creData, 'domain:exDate')) }
        end


        def create_contact(create, extension, name, options)
          extensions = options.dup
          extensions.delete_if { |k,_| !CONTACT_EXTENSION_KEYS.include?(k) }
          options.delete_if { |k,_| CONTACT_EXTENSION_KEYS.include?(k) }

          create << contact('create') do |node, ns|
            node << XML::Node.new('id', name, ns)

            options[:auth_info] ||= options.delete(:authInfo) || SecureRandom.hex(8).upcase
            options.delete(:authInfo) # Make sure its not present

            [:postal_info, :voice, :fax, :email, :auth_info, :disclose].each do |key|
              value = options[key]
              next if value.nil?

              case key
              when :postal_info
                node << XML::Node.new('postalInfo', nil, ns).tap do |post|
                  post['type'] = 'loc'
                  create_contact_postal_info(post, value, ns)
                end
              when :disclose
                node << XML::Node.new('disclose', nil, ns).tap do |d|
                  d["flag"] = "1"
                  Array(value).each do |v|
                    d << XML::Node.new(v, ns)
                  end
                end
              when :auth_info
                node << XML::Node.new('authInfo', nil, ns).tap do |n|
                  n << XML::Node.new('pw', value, ns)
                end
              when :voice, :fax, :email
                name = key.to_s.gsub('_', '-')
                node << XML::Node.new(name, value, ns)
              end
            end
          end

          unless extensions.empty?
            extension << contact_ext('create') do |node, ns|
              CONTACT_EXTENSION_KEYS.each do |key|
                value = extensions[key]
                next if value.nil?

                case key
                when :opt_out
                  node << XML::Node.new('opt-out', value ? 'Y' : 'N', ns)
                when :trad_name, :type, :co_no
                  name = key.to_s.gsub('_','-')
                  node << XML::Node.new(name, value, ns)
                end
              end
            end
          end
        end

        # @param [XML::Node] node XML Node to add data to
        # @param [Hash] data Information to add to +node+
        # @param [XML::Namespace] ns XML Namespace to create new nodes under
        def create_contact_postal_info(node, data, ns)
          [:name, :org, :addr].each do |key|
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

        def create_contact_response(resp)
          creData = resp.data.find('//contact:creData', namespaces).first
          { :name => node_value(creData, 'contact:id'),
            :crDate => Time.parse(node_value(creData, 'contact:crDate')) }
        end

        def create_host(create, extension, name, options)
          create << host('create') do |node, ns|
            node << XML::Node.new('name', name, ns);

            options.each do |key, value|
              case key
              when :v4, :v6
                node << XML::Node.new('addr', value, ns).tap do |addr|
                  addr['ip'] = key.to_s
                end
              end
            end
          end
        end

        def create_host_response(resp)
          creData = resp.data.find('//host:creData', namespaces).first
          { :name => node_value(creData, 'host:name'),
            :crDate => Time.parse(node_value(creData, 'host:crDate')) }
        end
    end
  end
end
