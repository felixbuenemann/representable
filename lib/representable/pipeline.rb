module Representable
  # Allows to implement a pipeline of filters where a value gets passed in and the result gets
  # passed to the next callable object.
  class Pipeline < Array
    include Uber::Callable

    Stop = Class.new

    # options is mutuable.
    def call(input, options)
      inject(input) do |memo, block|
        res = evaluate(block, memo, options)
        return(Stop)if Stop == res
        res
      end
    end

  private
    def evaluate(block, input, options)
      block.call(input, options)
    end
  end


  # Collect applies a pipeline to each element of input.
  class Collect < Pipeline
    # when stop, the element is skipped. (should that be Skip then?)
    def call(input, options)
      arr = []
      input.each_with_index do |item_fragment, i|
        result = super(item_fragment, options.merge(index: i)) # DISCUSS: NO :fragment set.
        Pipeline::Stop == result ? next : arr << result
      end
      arr
    end

    class Hash < Pipeline
      def call(input, options)
        {}.tap do |hsh|
          input.each { |key, item_fragment|
            hsh[key] = super(item_fragment, options) }# DISCUSS: NO :fragment set.
        end
      end
    end
  end
end
