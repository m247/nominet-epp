module NominetEPP
  module Custom
    class TagList < CustomRequest
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/nom-tag-1.0'

      def command_name
        'info'
      end
      def namespace_name
        'tag'
      end
      def namespace_uri
        NAMESPACE
      end

      def to_xml
        @namespaces ||= {}
        node = x_node('list')
        x_schemaLocation(node)

        node
      end
    end
  end
end
