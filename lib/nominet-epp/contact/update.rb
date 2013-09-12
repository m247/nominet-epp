module NominetEPP
  module Contact
    class Update < Request
      def initialize(name, changes = {})
        @name = name
        @namespaces = {}

        extensions = (changes[:add] || {}).merge(changes[:chg] || {})
        extensions.delete_if { |k,_| !UpdateExtension::KEYS.include?(k) }

        changes[:add] && changes[:add].delete_if { |k,_| UpdateExtension::KEYS.include?(k) }
        changes[:rem] && changes[:rem].delete_if { |k,_| UpdateExtension::KEYS.include?(k) }
        changes[:chg] && changes[:chg].delete_if { |k,_| UpdateExtension::KEYS.include?(k) }

        @contact_ext = UpdateExtension.new(extensions) rescue nil

        @command    = EPP::Contact::Update.new(name, changes)
        @extension  = EPP::Requests::Extension.new(@contact_ext) rescue nil
      end
    end

    class UpdateExtension < RequestExtension
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
        node = x_node('update')
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
