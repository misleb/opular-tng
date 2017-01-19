class Compiler
  def self.run(element)
    composite_link = compile_nodes(element, true)

    ->(scope) do
      element.scope = scope
      composite_link.call(scope, [element])
    end
  end

  def self.compile_nodes(elements, is_root)
    link_functions = []

    (is_root ? [elements] : elements).each_with_index do |elem, i|
      node_link = apply_directives_to_element(collect_directives(elem), elem)
      child_link = nil

      if elem.children.any?
        child_link = compile_nodes(elem.children, false)
      end

      if node_link && node_link.scope
        elem.addClass('op-scope')
      end

      if node_link || child_link
        link_functions << {
          node_link: node_link,
          child_link: child_link,
          idx: i
        }
      end
    end

    # composite link function
    ->(scope, link_nodes) do
      link_functions.each do |obj|
        if obj[:node_link]
          if obj[:node_link].scope
            link_nodes[obj[:idx]].scope = scope = scope._new
          end
          obj[:node_link].call(obj[:child_link], scope, link_nodes[obj[:idx]])
        elsif obj[:child_link]
          obj[:child_link].call(scope, link_nodes[obj[:idx]].children)
        end
      end
    end
  end

  def self.apply_directives_to_element(dirs, elem)
    return nil unless dirs.any?

    link_functions = []
    new_scope_directive = nil

    dirs.each do |dir|
      if dir.scope
        new_scope_directive = new_scope_directive || dir
      end

      if link = dir.compile(elem)
        link_functions << link
      end
    end

    node_link = ExtendedProc.new do |child_link, scope, element|
      child_link.call(scope, element.children) if child_link

      link_functions.each do |fn|
        fn.call(scope, element)
      end
    end

    node_link.scope = new_scope_directive && new_scope_directive.scope
    node_link
  end

  def self.collect_directives(elem)
    puts "Got elem: #{elem.attributes.all}"

    elem.attributes.all.inject([]) do |memo, pair|
      puts "Checking #{memo}, #{pair}"
      if dir = Directive::Registry[pair[0]]
        memo << dir.new
      end

      memo
    end
  end

  class ExtendedProc
    attr_accessor :scope

    def initialize(&block)
      @proc = block
    end

    def call(*args)
      @proc.call(*args)
    end
  end
end