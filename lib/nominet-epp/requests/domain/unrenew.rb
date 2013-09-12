module NominetEPP
  module Domain
    class Unrenew < CustomRequest
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/std-unrenew-1.0'

      def initialize(*names)
        @names = names
      end

      def command_name
        'update'
      end
      def namespace_name
        'u'
      end
      def namespace_uri
        NAMESPACE
      end

      def to_xml
        @namespaces ||= {}
        node = x_node('unrenew')
        x_schemaLocation(node)

        @names.each do |name|
          node << x_node('domainName', name)
        end

        node
      end
    end
  end
end
