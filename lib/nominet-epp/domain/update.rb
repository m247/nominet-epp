module NominetEPP
  module Domain
    class Update < Request
      def initialize(name, changes = {})
        @name = name
        @namespaces = {}

        extensions = (changes[:add] || {}).merge(changes[:chg] || {})
        extensions.delete_if { |k,_| !UpdateExtension::KEYS.include?(k) }

        changes[:add] && changes[:add].delete_if { |k,_| UpdateExtension::KEYS.include?(k) }
        changes[:rem] && changes[:rem].delete_if { |k,_| UpdateExtension::KEYS.include?(k) }
        changes[:chg] && changes[:chg].delete_if { |k,_| UpdateExtension::KEYS.include?(k) }

        dnssec = {}
        dnssec[:add] = changes[:add] && changes[:add].delete(:ds)
        dnssec[:rem] = changes[:rem] && changes[:rem].delete(:ds)
        dnssec[:chg] = changes[:chg] && changes[:chg].delete(:ds)

        @domain_ext = UpdateExtension.new(extensions) rescue nil
        @secdns_ext = UpdateSecDNSExtension.new(dnssec) rescue nil

        @command    = EPP::Domain::Update.new(name, changes)
        @extension  = EPP::Requests::Extension.new(@domain_ext, @secdns_ext) rescue nil
      end

      def namespaces
        ext_ns = @extension && @extension.namespaces || {}
        @command.namespaces.merge(ext_ns)
      end
    end

    class UpdateExtension < RequestExtension
      KEYS = [:first_bill, :recur_bill, :auto_bill, :next_bill,
        :auto_period, :next_period, :renew_not_required, :notes, :reseller]

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
        node = x_node('update')
        x_schemaLocation(node)

        KEYS.each do |key|
          value = @attributes[key]
          next if value.nil? || value == ''

          case key
          when :notes
            Array(value).each do |note|
              node << x_node('notes', note)
            end
          when :renew_not_required
            node << x_node('renew-not-required', value ? 'Y' : 'N')
          else
            name = key.to_s.gsub('_', '-')
            node << x_node(name, value.to_s)
          end
        end

        node
      end
    end

    class UpdateSecDNSExtension < RequestExtension
      NAMESPACE = 'urn:ietf:params:xml:ns:secDNS-1.1'

      def initialize(attributes)
        @add = Array(attributes[:add])
        @rem = Array(attributes[:rem])
        @chg = Array(attributes[:chg])

        raise ArgumentError, "must provide :add, :rem or :chg keys" if @add.empty? && @rem.empty? && @chg.empty?

        @namespaces = {}
      end

      def namespace_uri
        NAMESPACE
      end
      def namespace_name
        'secDNS'
      end

      def to_xml
        node = x_node('update')
        x_schemaLocation(node)

        if @rem[0] == :all || @rem[0] == 'all'
          node << x_node('rem').tap do |n|
            n << x_node('all', 'true')
          end
        elsif !@rem.empty?
          node << x_node('rem').tap do |n|
            @rem.each do |ds|
              n << x_node('dsData').tap do |dsData|
                dsData << x_node('keyTag', ds[:key_tag].to_s)
                dsData << x_node('alg', ds[:alg].to_s)
                dsData << x_node('digestType', ds[:digest_type].to_s)
                dsData << x_node('digest', ds[:digest].gsub(/\s/,''))
              end
            end
          end
        end

        if @add && !@add.empty?
          node << x_node('add').tap do |n|
            @add.each do |ds|
              n << x_node('dsData').tap do |dsData|
                dsData << x_node('keyTag', ds[:key_tag].to_s)
                dsData << x_node('alg', ds[:alg].to_s)
                dsData << x_node('digestType', ds[:digest_type].to_s)
                dsData << x_node('digest', ds[:digest].gsub(/\s/,''))
              end
            end
          end
        end

        if @chg && !@chg.empty?
          # Nominet don't support maxSigLife so nothing happens here
        end

        node
      end
    end
  end
end
