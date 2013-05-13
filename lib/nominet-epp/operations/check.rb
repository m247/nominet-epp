module NominetEPP
  module Operations
    # EPP Check Operation
    module Check
      # Check the availablity of one or more domain names
      #
      # @param [Symbol] entity Type of entity to check, :domain, :contact or :host
      # @param [String, ...] names List of names to check
      # @return [false] request failed
      # @return [true] the domain name is available
      # @return [Hash<String,Boolean>] availability by domain name
      def check(entity, *names)
        raise "Unsupported entity #{entity}" unless [:domain, :contact, :host].include?(entity)

        instrument :check, :entity => entity, :names => names do
          resp = instrument 'check.request', :entity => entity do
            @client.check do
              case entity
              when :domain
                domain('check') do |node, ns|
                  names.each do |name|
                    node << XML::Node.new('name', name, ns)
                  end
                end
              when :contact
                contact('check') do |node, ns|
                  names.each do |id|
                    node << XML::Node.new('id', id, ns)
                  end
                end
              when :host
                host('check') do |node, ns|
                  names.each do |name|
                    node << XML::Node.new('name', name, ns)
                  end
                end
              end
            end
          end

          return false unless resp.success?

          if entity == :domain
            @check_limit = check_abuse_limit(resp.extension)
          end

          xpath = case entity
          when :domain then '//domain:name'
          when :contact then '//contact:id'
          when :host then '//host:name'
          end

          instrument 'check.parse', :entity => entity do
            result = resp.data.find(xpath, namespaces).inject({}) do |hash, node|
              hash[node.content.strip] = node['avail'] == '1'
              hash
            end

            result.size > 1 ? result : result.values.first
          end
        end
      end

      protected
        def check_abuse_limit(extension)
          extension.find('//domain-nom-ext:chkData/@abuse-limit', namespaces).first.value.to_i
        end
    end
  end
end
