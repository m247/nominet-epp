module NominetEPP
  module Domain
    class Create < Request
      def initialize(name, options = {})
        @name = name
        @options = options
        @namespaces = {}

        @extensions = @options.dup
        @extensions.delete_if { |k,_| !CreateExtension::KEYS.include?(k) }
        @options.delete_if    { |k,_|  CreateExtension::KEYS.include?(k) }

        @options[:auth_info] ||= {:pw => SecureRandom.hex(8) }

        @domain_ext = CreateExtension.new(@extensions) rescue nil
        @secdns_ext = CreateSecDNSExtension.new(@options.delete(:ds)) rescue nil

        @command    = EPP::Domain::Create.new(@name, @options)
        @extension  = EPP::Requests::Extension.new(@domain_ext, @secdns_ext) rescue nil
      end

      def namespaces
        ext_ns = @extension && @extension.namespaces || {}
        @command.namespaces.merge(ext_ns)
      end
    end

    class CreateExtension < RequestExtension
      KEYS = [:first_bill, :recur_bill, :auto_bill, :next_bill,
        :auto_period, :next_period, :notes, :reseller]
      NAMESPACE = 'http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2'

      def initialize(attributes)
        raise ArgumentError, "must provide Hash of #{KEYS.map(&:inspect).join(", ")}" if attributes.nil? || attributes.empty?
        @attributes = attributes
        @namespaces = {}
      end

      def namespace_uri
        NAMESPACE
      end
      def namespace_name
        'domain-ext'
      end

      def to_xml
        node = x_node('create')
        x_schemaLocation(node)

        KEYS.each do |key|
          value = @attributes[key]
          next if value.nil? || value == ''

          case key
          when :notes
            Array(value).each do |note|
              node << x_node('notes', note)
            end
          else
            name = key.to_s.gsub('_', '-')
            node << x_node(name, value.to_s)
          end
        end

        node
      end
    end

    class CreateSecDNSExtension < RequestExtension
      NAMESPACE = 'urn:ietf:params:xml:ns:secDNS-1.1'

      def initialize(attributes)
        raise ArgumentError, "must provide Array of Hash or Hash of :key_tag, :alg, :digest_type and :digest" if attributes.nil? || attributes.empty?
        @attributes = attributes
        @namespaces = {}
      end

      def namespace_uri
        NAMESPACE
      end
      def namespace_name
        'secDNS'
      end

      def to_xml
        node = x_node('create')
        x_schemaLocation(node)

        Array(@attributes).each do |attributes|
          node << x_node('dsData').tap do |dsData|
            dsData << x_node('keyTag', attributes[:key_tag].to_s)
            dsData << x_node('alg', attributes[:alg].to_s)
            dsData << x_node('digestType', attributes[:digest_type].to_s)
            dsData << x_node('digest', attributes[:digest].gsub(/\s+/, ''))
          end
        end

        node
      end
    end
  end
end
