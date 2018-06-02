# Lazy initialization of the provided Ruby block.
#
# @example
#   CALC = lazy { long_calculation } # return quickly without calling block
#   # Do other things
#   CALC.result # call block, return result
class LazyObject < ::BasicObject
  def initialize(&block)
    @block = block
  end

  def __target_object__
    @__target_object__ ||= @block.call
  end

  def method_missing(method_name, *args, &block)
    __target_object__.send(method_name, *args, &block)
  end
end

def lazy(&block)
  LazyObject.new(&block)
end
