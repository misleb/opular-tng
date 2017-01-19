class Element
  attr_reader :attributes

  def initialize(selector)
    @root = MrubyJs.get_root_object
    puts "Creating new Element..."
    @node = @root.call("$", selector)
    @attributes = Attributes.new(self)
  end

  def first
    @first ||= @node.call("get", 0)
  end

  def scope
    Scope::Registry[data('_scope')]
  end

  def scope=(value)
    data('_scope', value._path)
    Scope::Registry[value._path] = value
  end

  def children
    return @children if @children

    (@children = []).tap do |kids|
      @node.call("children").call("each", proc { |i, node|
        kids << Element.new(node); nil
      })
    end
  end

  def each(&block)
    raise "Seriously?"
    # @node.call("each", proc { |i, node| yield Element.new(node); nil })
  end

  # Catch-all for jquery passthru
  def method_missing(name, *args, &block)
    if block_given?
      args << block
    end

    begin
      @node.call(name, *args)
    rescue ArgumentError
      first.get(name)
    end
  end

  class Attributes
    def initialize(element)
      @node = element
      @observers = Hash.new { |hash, key| hash[key] = [] }
    end

    def all
      i = 0
      attrs = @node.first.get("attributes")

      @all ||= {}.tap do |result|
        while attrs[i] do
          result[attrs[i].nodeName] = attrs[i].nodeValue
          i += 1
        end
      end
    end

    def set(key, value)
      @all = nil
      @node.attr(key, value)

      @observers[key].each do |fn|
        fn.call(value)
      end
    end

    def observe(attr, &block)
      @observers[attr] << block

      @node.scope._eval_async do
        block.call(self.all[attr])
      end
    end
  end
end