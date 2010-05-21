module NominetEPP
  module Operations
    module Delete
      def delete(name)
        resp = @client.delete do
          domain('delete') do |node, ns|
            node << XML::Node.new('name', name, ns)
          end
        end

        resp.success?
      end
    end
  end
end
