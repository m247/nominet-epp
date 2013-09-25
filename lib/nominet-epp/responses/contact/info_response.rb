module NominetEPP
  module Contact
    class InfoResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = EPP::Contact::InfoResponse.new(response)

        parse_truncated
        ext_inf_data
      end

      undef to_s

      def name
        @response.id
      end

      def type
        @contact_infData['type']
      end
      def trad_name
        @contact_infData['trad_name']
      end
      def co_no
        @contact_infData['co_no']
      end
      def opt_out
        @contact_infData['opt_out']
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

      def method_missing(method, *args, &block)
        return super unless @response.respond_to?(method)
        return @truncated[method.to_s] if @truncated.has_key?(method.to_s) # only do truncated if response would handle it
        @response.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private)
        @response.respond_to?(method, include_private)
      end

      def namespaces
        { 'warning' => 'http://www.nominet.org.uk/epp/xml/std-warning-1.1',
          'contact-ext' => 'http://www.nominet.org.uk/epp/xml/contact-nom-ext-1.0' }
      end

      protected
        def ext_inf_data
          @contact_infData = {}
          Array(@response.extension).each do |node|
            next unless node.name == 'infData'
            node.find('//contact-ext:infData', namespaces).each do |infData|
              infData.children.each do |child|
                next if child.empty?

                key = child.name.gsub('-', '_')
                case key
                when 'opt_out'
                  @contact_infData['opt_out'] = child.content.strip == 'Y'
                else
                  @contact_infData[key] = child.content.strip
                end
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
