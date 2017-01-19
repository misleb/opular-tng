# This is the entrypoint file for webruby

require 'element'
require 'scope'
require 'directive'
require 'compiler'
require 'q'

elem = Element.new("#container")

Element.new("body").on("irb") do |e, cmd|
   puts Kernel.eval(cmd)
end


