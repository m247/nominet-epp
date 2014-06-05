module NominetEPP
  module Domain
    class Check < Request
      def initialize(*names)
        rights = names.last.is_a?(Hash) ? names.pop : nil
        names  = names.compact # handle nil being passed for rights

        @command = EPP::Domain::Check.new(*names)

        if rights && !rights.empty?
          raise ArgumentError, "cannot check direct rights on more than one name" if names.count > 1
          @rights_ext = DirectRightsExtension.new(rights)
          @extension  = EPP::Requests::Extension.new(@rights_ext) rescue nil
        end
      end

      class DirectRightsExtension < RequestExtension
        KEYS = [:postal_info, :email, :registrant]
        NAMESPACE = 'http://www.nominet.org.uk/epp/xml/nom-direct-rights-1.0'

        def initialize(attributes)
          raise ArgumentError, "must provide Hash with one of #{KEYS.map(&:inspect).join(", ")}" if attributes.nil? || attributes.empty?

          if attributes.has_key?(:postal_info)
            unless attributes.has_key?(:email)
              raise ArgumentError, "must provide :email when using :postal_info"
            end
          end


          if attributes.has_key?(:email)
            unless attributes.has_key?(:postal_info)
              raise ArgumentError, "must provide :postal_info when using :email"
            end
          end

          if attributes.has_key?(:registrant)
            if attributes.has_key?(:email) || attributes.has_key?(:postal_info)
              raise ArgumentError, ":registrant must be used on its own"
            end
          end

          @attributes = attributes
          @namespaces = {}
        end

        def namespace_uri
          NAMESPACE
        end
        def namespace_name
          'nom-direct-rights'
        end

        def contact_node(name, value = nil)
          node = xml_node(name, value)
          node.namespaces.namespace = x_namespace(node,
            'contact', EPP::Contact::NAMESPACE)
          node
        end

        def to_xml
          node = x_node('check')
          x_schemaLocation(node)

          KEYS.each do |key|
            value = @attributes[key]
            next if value.nil? || value == ''

            case key
            when :postal_info
              node << x_node('postalInfo').tap do |postalInfo|
                postalInfo['type'] = 'loc'

                @namespaces['contact'] = xml_namespace(postalInfo, 'contact', EPP::Contact::NAMESPACE)
                x_schemaLocation(postalInfo, EPP::Contact::SCHEMA_LOCATION)

                postalInfo << contact_node('name', value[:name])
                postalInfo << contact_node('org', value[:org]) if value[:org]

                postalInfo << contact_node('addr').tap do |addr|
                  addr << contact_node('street', value[:addr][:street]) if value[:addr][:street]
                  addr << contact_node('city', value[:addr][:city])
                  addr << contact_node('sp', value[:addr][:sp]) if value[:addr][:sp]
                  addr << contact_node('pc', value[:addr][:pc]) if value[:addr][:pc]
                  addr << contact_node('cc', value[:addr][:cc])
                end
              end
            else
              name = key.to_s.gsub('_', '-')
              node << x_node(name, value.to_s)
            end
          end

          node
        end
      end
    end
  end
end
