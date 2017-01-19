module Directive
  Registry = {}

  class Base
    attr_reader :restrict, :priority, :terminal, :multi_element, :transclude, :scope
    attr_accessor :name, :__end, :__start

    def initialize
      @restrict = 'EA'
      @name = "Base"
      @priority = 0
    end

    def compile(element)
      if respond_to? :link
        method :link
      end
    end

    # TODO add a compile super method to reset memoized values
  end

  class OpRepeat < Base
    Registry['op-repeat'] = self

    def initialize
      super

      @restrict = 'A'
      @name = "op-repeat"
      @transclude = true
      @terminal = true
    end

    def syntax
      "'_item_' in '_item_ in _collection_' should be an identifier or '(_key_, _value_)' expression, but got '{0}'."
    end

    def compile(element)
      expression = element.attributes.all[@name]

      match = expression.match(/^\s*([\s\S]+?)\s+in\s+([\s\S]+?)(?:\s+as\s+([\s\S]+?))?(?:\s+track\s+by\s+([\s\S]+?))?\s*$/)

      raise syntax if !match

      lhs = match[1]
      rhs = match[2]
      aliasAs = match[3]
      trackByExp = match[4]

      match = lhs.match(/^(?:(\s*[\$\w]+)|\(\s*([\$\w]+)\s*,\s*([\$\w]+)\s*\))$/);

      raise syntax if !match

      valueIdentifier = match[3] || match[1]
      keyIdentifier = match[2]
    end
  end

  class OpClick < Base
    Registry['op-click'] = self

    def initialize
      super

      @restrict = 'A'
      @name = "op-click"
      @scope = true
    end

    def link(scope, element)
      element.click do
        scope._eval(element.attributes.all[@name])
      end
    end
  end

  class OpHide < Base
    Registry['op-hide'] = self

    def initialize
      super

      @restrict = 'A'
      @name = "op-hide"
      @scope = true
    end

    def link(scope, element)
      element.attributes.observe(@name) do |value|
        if scope._eval(value)
          element.hide
        else
          element.show
        end
      end
    end
  end
end