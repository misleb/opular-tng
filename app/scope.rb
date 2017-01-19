class Scope
  DIGEST_TTL = 10

  attr_reader :_watchers, :_async_queue, :_phase, :_apply_async_queue,
              :_apply_async_id, :_post_digest_queue, :_children, :_parent,
              :_isolated, :_path

  Registry = {}

  def self.root
    Registry["0"] ||= Scope.new
  end

  def initialize(parent = nil)
    @_async_queue = []
    @table = {}
    @_parent = parent
    @_children = []
    @_path = parent ? parent._next_child_path(self) : "0"
    @_child_sequence = 0
  end

  def _new
    Scope.new(self)
  end

  def _next_child_path(child)
    @_children << child
    "#{@_path}:#{@_child_sequence += 1}"
  end

  def _all_scopes(&block)
    if yield(self)
      @_children.all? do |child|
        child._all_scopes(&block)
      end
    else
      false
    end
  end

  def _eval_async(expr = nil, &block)
    #if !@__phase && @__async_queue.empty?
    #  Timeout.new(0) do
    #    self._root._digest if @__async_queue.any?
    #  end
    #end

    @_async_queue << (block_given? ? block : expr)
  end

  def _digest_once
    _all_scopes do |scope|
      scope._digest
    end
  end

  def _digest
    _consume_queue(@_async_queue)
  end

  def _consume_queue(queue)
    queue.size.times do
      expr = queue.shift

      begin
        _eval(expr)
      rescue => e
        puts e.inspect
      end
    end
  end

  def _eval(expr, *locals)
    if expr.is_a?(Proc)
      expr.call
    elsif expr.is_a?(String)
      self.instance_exec(*locals, &Kernel.eval("proc {\n#{expr}\n}"))
    else
      proc {}
    end
  end

  def [](name)
    _parent_or_table(name)
  end

  private

  def method_missing(name, *args)
    name = name.to_s

    if name.end_with? '='
      @table[name[0 .. -2].to_sym] = args[0]
    else
      _parent_or_table(name)
    end
  end

  def _parent_or_table(name)
    if @table.key?(name.to_sym)
      @table[name.to_sym]
    elsif @_parent && !@_isolated
      @_parent.send(name.to_sym)
    else
      puts "Warning: Referenced unknown scope method or variable #{name}"
    end
  end
end