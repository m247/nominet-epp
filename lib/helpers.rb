module NominetEPP
  # Helper methods
  module Helpers
    # @param [String, Array] nameservers Nameserver host name or array of host names or hashes
    # @param [XML::Namespace] ns XML Namespace to create the elements with
    # @return [XML::Node] +ns+ element of +host+ elements
    # @see domain_host_xml
    def domain_ns_xml(nameservers, ns)
      ns_el = XML::Node.new('ns', nil, ns)

      case nameservers.class
      when String
        ns_el << (XML::Node.new('host', nil, ns) << XML::Node.new('hostName', nameservers, ns))
      when Array
        nameservers.each do |nameserver|
          ns_el << domain_host_xml(nameserver, ns)
        end
      else
        raise ArgumentError, "nameservers must either be a string or array of strings"
      end

      ns_el
    end

    # @param [String, Hash] nameserver Nameserver host name or hash of +:name+ and +:v4+ or +:v6+ address
    # @param [XML::Namespace] ns XML Namespace to create the elements with
    # @return [XML::Node] +host+ element with +hostName+ and optionally +ip+ subelements
    def domain_host_xml(nameserver, ns)
      host = XML::Node.new('host', nil, ns)

      case nameserver.class
      when String
        host << XML::Node.new('hostName', nameserver, ns)
      when Hash
        host << XML::Node.new('hostName', nameserver[:name], ns)
        if nameserver[:v4]
          n = XML::Node.new('hostAddr', nameserver[:v4], ns)
          n['ip'] = 'v4'
          host << n
        end
        if nameserver[:v6]
          n = XML::Node.new('hostAddr', nameserver[:v6], ns)
          n['ip'] = 'v6'
          host << n
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
      fields.each do |k,v|
        case k
        when :contacts
          v.each do |c|
            node << (c_node = XML::Node.new('contact', nil, ns))
            c_node['order'] = c.delete(:order)
            c_node['type'] = 'admin'

            c_node << contact(c.delete(:action) || 'create') do |cn, cns|
              c.each do |l,w|
                cn << XML::Node.new(l, w, cns)
              end
            end
          end
        when :addr  # Limitation, can only handle one addr at a time
          node << (a_node = XML::Node.new('addr', nil, ns))
          a_node['type'] = 'admin'
          v.each do |l,w|
            a_node << XML::Node.new(l, w, ns)
          end
        else
          node << XML::Node.new(k.to_s.gsub('_', '-'), v, ns)
        end
      end
    end
  end
end
