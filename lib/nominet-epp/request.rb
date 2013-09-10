module NominetEPP
  class Request
    attr_reader :command, :extension

    def command_name
      @command_name ||= command.name
    end

    # Creates and returns a new XML node
    #
    # @param [String] name of the node to create
    # @param [String,XML::Node,nil] value of the node
    # @return [XML::Node]
    def xml_node(name, value = nil)
      XML::Node.new(name, value)
    end

    # Creates and returns a new XML namespace
    #
    # @param [XML::Node] node XML node to add the namespace to
    # @param [String] name Name of the namespace to create
    # @param [String] uri URI of the namespace to create
    # @return [XML::Namespace]
    def xml_namespace(node, name, uri, namespaces = {})
      XML::Namespace.new(node, name, uri)
    end
  end

  class ExtendedRequest < Request
    def initialize
      @extension = ExtendedRequestExtensionProxy.new(self)
    end
    
    def set_namespaces(namespaces)
      @namespaces = namespaces
    end

    def namespace_uri
      raise NotImplementedError
    end
    def namespace_name
      case namespace_uri
      when /\Aurn\:/
        namespace_uri.split(':').last.split('-',2).first.to_sym
      else
        namespace_uri.split('/').last.split('-')[0...-1].join('-').to_sym
      end        
    end

    def schemaLocation
      "#{namespace_uri} #{schema_name(namespace_uri)}.xsd"
    end

    protected
      def x_node(name, value = nil)
        node = xml_node(name, value)
        node.namespaces.namespace = x_namespace(node)
        node
      end

      def x_namespace(node, name = namespace_name, ns = namespace_uri)
        return @namespaces[name] if @namespaces.has_key?(name)
        @namespaces[name] = xml_namespace(node, name, ns)
      end

      def x_schemaLocation(node, sL = schemaLocation)
        xattr = XML::Attr.new(node, "schemaLocation", sL)
        xattr.namespaces.namespace = x_namespace(node, 'xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      end
      
      # Returns the name of the given schema
      # @internal
      # @param [String] urn Schema URN or URI
      # @return [String] the name of the given schema
      def schema_name(urn)
        case urn
        when /\Aurn\:/
          urn.split(':').last
        else
          urn.split('/').last
        end
      end
  end
  
  class ExtendedRequestExtensionProxy
    def initialize(delegate)
      @delegate = delegate
    end
    def set_namespaces(namespaces)
      @delegate.set_namespaces(namespaces)
    end
    def to_xml
      @delegate.extension_xml
    end
  end

  class CustomRequest < Request
    attr_reader :namespaces

    def command
      self
    end

    def set_namespaces(namespaces)
      @namespaces = namespaces
    end

    def namespace_uri
      raise NotImplementedError
    end
    def namespace_name
      case namespace_uri
      when /\Aurn\:/
        namespace_uri.split(':').last.split('-',2).first.to_sym
      else
        namespace_uri.split('/').last.split('-')[0...-1].join('-').to_sym
      end        
    end

    def schemaLocation
      "#{namespace_uri} #{schema_name(namespace_uri)}.xsd"
    end

    protected
      def x_node(name, value = nil)
        node = xml_node(name, value)
        node.namespaces.namespace = x_namespace(node)
        node
      end

      def x_namespace(node, name = namespace_name, ns = namespace_uri)
        return @namespaces[name] if @namespaces.has_key?(name)
        @namespaces[name] = xml_namespace(node, name, ns)
      end

      def x_schemaLocation(node, sL = schemaLocation)
        xattr = XML::Attr.new(node, "schemaLocation", sL)
        xattr.namespaces.namespace = x_namespace(node, 'xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      end
      
      # Returns the name of the given schema
      # @internal
      # @param [String] urn Schema URN or URI
      # @return [String] the name of the given schema
      def schema_name(urn)
        case urn
        when /\Aurn\:/
          urn.split(':').last
        else
          urn.split('/').last
        end
      end
  end
end
