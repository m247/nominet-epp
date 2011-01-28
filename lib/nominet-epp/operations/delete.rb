module NominetEPP
  module Operations
    # EPP Delete Operation
    module Delete
      # Delete a domain from the registry
      #
      # @param [String] name Domain name
      # @return [Boolean] success status
      def delete(name)
        @resp = @client.delete do
          domain('delete') do |node, ns|
            node << XML::Node.new('name', name, ns)
          end
        end

        @resp.success?
      end
    end
  end
end
