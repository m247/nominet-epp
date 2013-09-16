module NominetEPP
  module Custom
    class Handshake < CustomRequest
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/std-handshake-1.0'

      def initialize(case_id, registrant = nil)
        @case_id = case_id
        @registrant = registrant
      end

      def command_name
        'update'
      end
      def namespace_name
        'h'
      end
      def namespace_uri
        NAMESPACE
      end

      def to_xml
        @namespaces ||= {}
        node = x_node('accept')
        x_schemaLocation(node)

        node << x_node('caseId', @case_id)
        
        if @registrant
          node << x_node('registrant', @registrant)
        end

        node
      end
    end
  end
end
