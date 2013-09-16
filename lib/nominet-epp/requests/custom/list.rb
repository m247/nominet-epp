module NominetEPP
  module Custom
    class List < CustomRequest
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/std-list-1.0'

      def initialize(type, month)
        month = month.strftime('%Y-%m') if month.respond_to?(:strftime)
        @month = month
        @type  = type
      end

      def command_name
        'info'
      end
      def namespace_name
        'l'
      end
      def namespace_uri
        NAMESPACE
      end

      def to_xml
        @namespaces ||= {}
        node = x_node('list')
        x_schemaLocation(node)

        case @type
        when :registration, 'registration', :month, 'month'
          node << x_node('month', @month)
        when :expiry, 'expiry'
          node << x_node('expiry', @month)
        end

        node
      end
    end
  end
end
