module NominetEPP
  module Domain
    class InfoResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = EPP::Domain::InfoResponse.new(response)

        parse_truncated
        ext_inf_data
      end

      def nameservers
        @nameservers ||= @response.nameservers.each do |ns|
          ns['name'] = ns['name'].sub(/\.$/,'')
        end
      end
      
      def hosts
        @hosts ||= @response.hosts.map { |ns| ns.sub(/\.$/,'') }
      end

      def reg_status
        @domain_infData['reg-status']
      end

      def first_bill
        @domain_infData['first_bill']
      end
      def recur_bill
        @domain_infData['recur_bill']
      end
      def auto_bill
        @domain_infData['auto-bill']
      end
      def auto_period
        @domain_infData['auto-period']
      end
      def next_bill
        @domain_infData['next-bill']
      end
      def next_period
        @domain_infData['next-period']
      end
      def renew_not_required
        @domain_infData['renew-not-required']
      end
      def notes
        @domain_infData['notes']
      end
      def reseller
        @domain_infData['reseller']
      end

      def client_id
        @truncated['clID'] || @response.client_id
      end
      def creator_id
        @truncated['crID'] || @response.creator_id
      end
      def updator_id
        @truncated['upID'] || @response.updator_id
      end

      def ds
        @secDNS_infData
      end

      def method_missing(method, *args, &block)
        return super unless @response.respond_to?(method)
        return @truncated[method.to_s] if @truncated.has_key?(method.to_s) # only do truncated if response would handle it
        @response.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private)
        @response.respond_to?(method, include_private)
      end

      def namespaces
        { 'secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1',
          'warning' => 'http://www.nominet.org.uk/epp/xml/std-warning-1.1',
          'domain-ext' => 'http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2' }
      end

      protected
        def ext_inf_data
          @secDNS_infData = []
          @domain_infData = {}
          Array(@response.extension).each do |node|
            next unless node.name == 'infData'
            node.find('//domain-ext:infData', namespaces).each do |infData|
              infData.children.each do |child|
                next if child.empty?

                key = child.name.gsub('-', '_')
                case key
                when 'notes'
                  @domain_infData['notes'] ||= Array.new
                  @domain_infData['notes'] << child.content.strip
                else
                  @domain_infData[key] = child.content.strip
                end
              end
            end

            node.find('//secDNS:infData', namespaces).each do |infData|
              next if infData.empty?

              @secDNS_infData   = infData.find('secDNS:dsData', namespaces).map do |dsData|
                { :key_tag      => dsData.find('secDNS:keyTag', namespaces).first.content.strip,
                  :alg          => dsData.find('secDNS:alg', namespaces).first.content.strip,
                  :digest_type  => dsData.find('secDNS:digestType', namespaces).first.content.strip,
                  :digest       => dsData.find('secDNS:digest', namespaces).first.content.strip}
              end
            end
          end
        end
        def parse_truncated
          @truncated = {}
          Array(@response.extension).each do |node|
            next unless node.name == 'truncated-field'
            fieldName = node.attributes["field-name"]
            ns, field = fieldName.split(":", 2)
            content = node.content.strip
            content =~ /Full entry is '([^']*)'/
            content = $1

            @truncated[field.gsub('-','_')] = content
          end
        end
    end
  end
end
