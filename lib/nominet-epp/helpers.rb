module NominetEPP
  # Helper methods
  module Helpers
    # @param [String, Array] nameservers Nameserver host name or array of host names or hashes
    # @param [XML::Namespace] ns XML Namespace to create the elements with
    # @return [XML::Node] +ns+ element of +host+ elements
    # @see domain_host_xml
    def domain_ns_xml(nameservers, ns)
      ns_el = XML::Node.new('ns', nil, ns)

      case nameservers
      when String
        ns_el << domain_host_xml(nameservers, ns)
      when Array
        nameservers.each do |nameserver|
          ns_el << domain_host_xml(nameserver, ns)
        end
      else
        raise ArgumentError, "nameservers must either be a string or array"
      end

      ns_el
    end

    # @param [String, Hash] nameserver Nameserver host name or hash of +:name+ and +:v4+ or +:v6+ address
    # @param [XML::Namespace] ns XML Namespace to create the elements with
    # @return [XML::Node] +host+ element with +hostName+ and optionally +ip+ subelements
    def domain_host_xml(nameserver, ns)
      host = XML::Node.new('host', nil, ns)

      case nameserver
      when String
        host << XML::Node.new('hostName', nameserver, ns)
      when Hash
        host << XML::Node.new('hostName', nameserver[:name], ns)
        if nameserver[:v4]
          host << XML::Node.new('hostAddr', nameserver[:v4], ns).tap do |n|
            n['ip'] = 'v4'
          end
        end
        if nameserver[:v6]
          host << XML::Node.new('hostAddr', nameserver[:v6], ns).tap do |n|
            n['ip'] = 'v6'
          end
        end
      end

      host
    end

    # Adds the attributes from the fields to the +node+.
    #
    # @param [Hash] fields Account attributes to marshal
    # @param [XML::Node] node XML Node to add the attributes to
    # @param [XML::Namespace] ns XML Namespace to create the elements under
    def account_fields_xml(fields, node, ns)
      [:trad_name, :type, :co_no, :opt_out, :addr, :contacts].each do |k|
        next if fields[k].nil?
        case k
        when :contacts
          account_contacts_to_xml(fields[k], ns) do |n|
            node << n
          end
        when :addr  # Limitation, can only handle one addr at a time
          node << addr_to_xml(fields[k], ns)
        else
          node << generic_field_to_xml(k, fields[k], ns) unless fields[k] == ''
        end
      end
    end

    # Creates an XML node with the dashed form of the +name+.
    #
    # @param [String] name Element name, underscores will be converted to hyphens
    # @param [String] value Element value
    # @param [XML::Namespace] ns XML Namespace to create the element under
    # @return [XML::Node]
    def generic_field_to_xml(name, value, ns)
      XML::Node.new(name.to_s.gsub('_', '-'), value, ns)
    end

    # Massage the contacts to ensure they have an :order parameter
    #
    # @param [Array<Hash>] contacts Array of contact attributes
    # @return [Array<Hash>] Fixed array of contact attributes
    def fixup_account_contacts(contacts)
      if contacts.all? { |c| c.has_key? :order }
        return contacts.sort { |a,b| a[:order].to_i <=> b[:order].to_i }
      elsif contacts.any? { |c| c.has_key? :order }
        unordered = contacts.map {|c| c if c[:order].nil? }.compact
        ordered = Array.new
        contacts.each do |c|
          next if c[:order].nil?
          ordered[c[:order].to_i - 1] = c
        end

        contacts = ordered.map do |i|
          unless i.nil? then i
          else unordered.shift
          end
        end + unordered
      end

      contacts.each_with_index { |c,i| c[:order] = (i+1).to_s }
    end

    # Creates and array of XML::Node objects for each contact passed.
    #
    # @param [Array] contacts Array of contacts
    # @param [XML::Namespace] ns XML Namespace to create the elements under
    # @yield [node]
    # @yieldparam [XML::Node] node XML contact element
    # @return [Array] array of XML contact nodes
    def account_contacts_to_xml(contacts, ns)
      raise ArgumentError, "contacts must be an Array" unless contacts.is_a?(Array)
      raise ArgumentError, "ns must be an xml namespace" unless ns.is_a?(XML::Namespace)

      contacts = fixup_account_contacts(contacts)

      contacts[0,3].map do |contact|
        account_contact_to_xml(contact, ns).tap do |n|
          yield n if block_given?
        end
      end
    end

    # Creates an XML contact element
    #
    # @param [Hash] contact Contact attributes
    # @param [XML::Namespace] ns XML Namespace to create the elements under
    # @return [XML::Node] XML contact element
    def account_contact_to_xml(contact, ns)
      raise ArgumentError, "contact must be a hash" unless contact.is_a?(Hash)
      raise ArgumentError, "ns must be an xml namespace" unless ns.is_a?(XML::Namespace)

      XML::Node.new('contact', nil, ns).tap do |node|
        node['order'] = contact.delete(:order).to_s if contact.has_key?(:order)
        node['type'] = 'admin'

        node << contact_to_xml(contact)
      end
    end

    # Creates an XML +contact:create+ or +contact:update+ element.
    #
    # The choice to create a +create+ or +update+ element is determined by the presence of
    # a +:roid+ key in the list of attributes.
    #
    # @param [Hash] contact Contact attributes
    # @return [XML::Node] XML contact:+action+ element with the attributes
    def contact_to_xml(contact)
      keys = [:roid, :name, :phone, :mobile, :email]
      raise ArgumentError, "contact must be a hash" unless contact.is_a?(Hash)
      raise ArgumentError, "Contact allowed keys are #{keys.join(', ')}" unless (contact.keys - keys).empty?
      raise ArgumentError, "Contact requires name and email keys" unless contact.has_key?(:name) && contact.has_key?(:email)

      action = contact[:roid].nil? || contact[:roid] == '' ? 'create' : 'update'
      contact(action) do |node, ns|
        keys.each do |key|
          next if contact[key].nil? || contact[key] == ''
          node << XML::Node.new(key, contact[key], ns)
        end
      end
    end

    # Creates an XML addr element
    #
    # @param [Hash] addr Address attributes
    # @param [XML::Namespace] ns XML Namespace to create the elements in
    # @return [XML::Node] XML addr element
    def addr_to_xml(addr, ns)
      keys = [:street, :locality, :city, :county, :postcode, :country]
      raise ArgumentError, "addr must be a hash" unless addr.is_a?(Hash)
      raise ArgumentError, "ns must be an xml namespace" unless ns.is_a?(XML::Namespace)
      raise ArgumentError, "Address allowed keys are #{keys.join(', ')}" unless (addr.keys - keys).empty?

      XML::Node.new('addr', nil, ns).tap do |a|
        keys.each do |key|
          next if addr[key].nil? || addr[key] == ''
          a << XML::Node.new(key, addr[key], ns)
        end
      end
    end
  end
end
