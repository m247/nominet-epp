module NominetEPP
  module Operations
    module Renew
      def renew(name, period = '2y')
        period = '2y'  # reset period to 2 years as nominet don't currently support other options

        unit = period[-1..1]
        num = period.to_i.to_s

        raise ArgumentError, "period suffix must either be 'm' or 'y'" unless %w(m y).include?(unit)

        resp = @client.renew do
          domain('renew') do |node, ns|
            node << XML::Node.new('name', name, ns)
            p = XML::Node.new('period', num, ns);
            p['unit'] = unit
            node << p
          end
        end

        return false unless resp.success?

        renData = resp.data.find('//domain:renData', data_namespaces(resp.data)).first
        renName = renData.find('domain:name', data_namespaces(resp.data)).first.content.strip
        renExp  = renData.find('domain:exDate', data_namespaces(resp.data)).first.content.strip

        raise "Renewed name #{renName} does not match #{name}" if renName != name
        return Time.parse(renExp)
      end
    end
  end
end
