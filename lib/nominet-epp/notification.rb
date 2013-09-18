require 'ostruct'
module NominetEPP
  class Notification
    NAMESPACE_URIS = {
      'urn:ietf:params:xml:ns:domain-1.0' => 'domain',
      'urn:ietf:params:xml:ns:contact-1.0' => 'contact',
      'http://www.nominet.org.uk/epp/xml/nom-abuse-feed-1.0' => 'abuse',
      'http://www.nominet.org.uk/epp/xml/std-notifications-1.0' => 'n',
      'http://www.nominet.org.uk/epp/xml/std-notifications-1.1' => 'n',
      'http://www.nominet.org.uk/epp/xml/std-notifications-1.2' => 'n',
      'http://www.nominet.org.uk/epp/xml/nom-notifications-2.1' => 'n' }

    def initialize(response)
      raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
      @response = response
      @parsed   = {}

      parse_response
    end

    def method_missing(method, *args, &block)
      return @parsed[method] if @parsed.has_key?(method)
      return super unless @response.respond_to?(method)
      @response.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private)
      @parsed.has_key?(method) || @response.respond_to?(method, include_private)
    end

    protected
      def parse_response
        ns   = NAMESPACE_URIS[@response.data.namespaces.namespace.href]
        name = @response.data.name

        method = :"parse_#{ns}_#{name}"
        if self.respond_to?(method, true)
          return self.send(method, @response.data)
        end
      end

      def parse_n_cancData(data)
        data.children.each do |node|
          case node.name
          when 'domainName'
            @parsed[:name] = node.content.strip
          when 'orig'
            @parsed[:originator] = node.content.strip
          end
        end
      end
      def parse_n_domainListData(data)
        data.children.map do |n|
          content = n.content.strip
          content == "" ? nil : content
        end.compact
      end
      def parse_n_relData(data)
        data.children.each do |node|
          case node.name
          when 'accountId'
            @parsed[:account_id] = node.content.strip
            @parsed[:account_moved?] = node['moved'] == 'Y'
          when 'from'
            @parsed[:from] = node.content.strip
          when 'registrarTag'
            @parsed[:registrar_tag] = node.content.strip
          when 'domainListData'
            @parsed[:domains] = parse_n_domainListData(node)
          end
        end
      end
      def parse_n_suspData(data)
        data.children.each do |node|
          case node.name
          when 'reason'
            @parsed[:reason] = node.content.strip
          when 'cancelDate'
            @parsed[:cancellation_date] = Time.parse(node.content.strip)
          when 'domainListData'
            @parsed[:domains] = parse_n_domainListData(node)
          end
        end
      end
      def parse_n_trnData(data)
        data.children.each do |node|
          case node.name
          when 'orig'
            @parsed[:originator] = node.content.strip
          when 'accountId'
            @parsed[:account_id] = node.content.strip
          when 'oldAccountId'
            @parsed[:old_account_id] = node.content.strip
          when 'domainListData'
            @parsed[:domains] = parse_n_domainListData(node)
          when 'infData'
            @parsed[:contact] = OpenStruct.new(parse_contact_infData(node))
          end
        end
      end
      def parse_contact_infData(data)
        parsed = {}
        data.children.each do |node|
          next if node.empty?
          case node.name
          when 'id'
            parsed[:id] = node.content.strip
          when 'roid'
            parsed[:roid] = node.content.strip
          when 'status'
            parsed[:status] = node['s'].to_s
          when 'postalInfo'
            parsed[:postal_info] = parse_contact_postalInfo(node)
          when 'email'
            parsed[:email] = node.content.strip
          when 'clID'
            parsed[:client_id] = node.content.strip
          when 'crID'
            parsed[:creator_id] = node.content.strip
          when 'crDate'
            parsed[:created_date] = Time.parse(node.content.strip)
          when 'upID'
            parsed[:updator_id] = node.content.strip
          when 'upDate'
            parsed[:updated_date] = Time.parse(node.content.strip)
          end
        end
        parsed
      end
      def parse_contact_postalInfo(data)
        parsed = {}
        data.children.each do |node|
          case node.name
          when 'name'
            parsed[:name] = node.content.strip
          when 'org'
            parsed[:org] = node.content.strip
          when 'addr'
            parsed[:addr] = parse_contact_addr(node)
          end
        end
        parsed
      end
      def parse_contact_addr(data)
        parsed = {}
        data.children.each do |node|
          case node.name
          when 'street'
            parsed[:street] = node.content.strip
          when 'city'
            parsed[:city] = node.content.strip
          when 'sp'
            parsed[:sp] = node.content.strip
          when 'pc'
            parsed[:pc] = node.content.strip
          when 'cc'
            parsed[:cc] = node.content.strip
          end
        end
        parsed
      end
      def parse_n_contactDelData(data)
        data.children.each do |node|
          case node.name
          when 'contactId'
            @parsed[:id] = node.content.strip
          when 'roid'
            @parsed[:roid] = node.content.strip
          end
        end
      end
  end
end
