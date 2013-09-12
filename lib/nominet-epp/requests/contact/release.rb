module NominetEPP
  module Contact
    class Release < CustomRequest
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/std-release-1.0'

      def initialize(name, tag)
        @name = name
        @tag  = tag
      end

      def command_name
        'update'
      end
      def namespace_name
        'r'
      end
      def namespace_uri
        NAMESPACE
      end

      def to_xml
        @namespaces ||= {}
        node = x_node('release')
        x_schemaLocation(node)

        node << x_node('registrant', @name)
        node << x_node('registrarTag', @tag)

        node
      end
    end
  end
end
