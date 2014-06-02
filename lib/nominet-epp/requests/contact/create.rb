module NominetEPP
  module Contact
    class Create < Request
      def initialize(name, options = {})
        @name = name
        @options = options
        @namespaces = {}

        @extensions = @options.dup
        @extensions.delete_if { |k,_| !CreateExtension::KEYS.include?(k) }
        @options.delete_if    { |k,_|  CreateExtension::KEYS.include?(k) }

        @options[:auth_info] ||= {:pw => SecureRandom.hex(8) }

        @contact_ext = CreateExtension.new(@extensions) rescue nil

        @command    = EPP::Contact::Create.new(@name, @options)
        @extension  = EPP::Requests::Extension.new(@contact_ext) rescue nil
      end
    end

    class CreateExtension < RequestExtension
      KEYS = [:trad_name, :type, :co_no, :opt_out]
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/contact-nom-ext-1.0'

      def initialize(attributes)
        raise ArgumentError, "must provide Hash of #{KEYS.map(&:inspect).join(", ")}" if attributes.nil? || attributes.empty?
        @attributes = attributes
        @namespaces = {}
      end

      def namespace_uri
        NAMESPACE
      end
      def namespace_name
        'contact-ext'
      end

      def to_xml
        node = x_node('create')
        x_schemaLocation(node)

        KEYS.each do |key|
          value = @attributes[key]
          next if value.nil? || value == ''

          case key
          when :opt_out
            node << x_node('opt-out', value ? 'Y' : 'N')
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
