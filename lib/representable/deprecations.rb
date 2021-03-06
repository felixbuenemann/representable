# WARNING: this will be removed in 3.0.
module Representable::Binding::Deprecation
  Options = Struct.new(:binding, :user_options, :represented, :decorator)

  module EvaluateOption
    def evaluate_option(name, input=nil, options={})
      return evaluate_option_with_deprecation(name, input, options, :user_options) if name==:as
      return evaluate_option_with_deprecation(name, input, options, :user_options) if name==:if
      return evaluate_option_with_deprecation(name, input, options, :user_options) if name==:getter
      return evaluate_option_with_deprecation(name, input, options, :doc, :user_options) if name==:writer
      return evaluate_option_with_deprecation(name, input, options, :input, :user_options) if name==:skip_render
      return evaluate_option_with_deprecation(name, input, options, :input, :user_options) if name==:skip_parse
      return evaluate_option_with_deprecation(name, input, options, :input, :user_options) if name==:serialize
      return evaluate_option_with_deprecation(name, input, options, :doc, :user_options) if name==:reader
      return evaluate_option_with_deprecation(name, input, options, :input, :index, :user_options) if name==:instance
      return evaluate_option_with_deprecation(name, input, options, :input, :index, :user_options) if name==:class
      return evaluate_option_with_deprecation(name, input, options, :input, :fragment, :user_options) if name==:deserialize
      return evaluate_option_with_deprecation(name, input, options, :input, :user_options) if name==:prepare
      return evaluate_option_with_deprecation(name, input, options, :input, :user_options) if name==:extend
      return evaluate_option_with_deprecation(name, input, options, :input, :user_options) if name==:setter
    end


    def evaluate_option_with_deprecation(name, input, options, *positional_arguments)
      unless proc = self[name]
        return # FIXME: why do we need this?
      end

      options[:input] = input


      __options = if self[:pass_options]
        warn %{[Representable] The :pass_options option is deprecated. Please access environment objects via options[:binding].
  Learn more here: http://trailblazerb.org/gems/representable/upgrading-guide.html#pass-options}
        Options.new(self, options[:user_options], options[:represented], options[:decorator])
      else
        # user_options
        options[:user_options]
      end
      # options[:user_options] = __options # TODO: always make this user_options in Representable 3.0.

      if proc.send(:proc?) or proc.send(:method?)
        arity = proc.instance_variable_get(:@value).arity if proc.send(:proc?)
        arity = send(:exec_context, options).method(proc.instance_variable_get(:@value)).arity if proc.send(:method?)
        if arity  != 1 or name==:getter or name==:if or name==:as
          warn %{[Representable] Positional arguments for `:#{name}` are deprecated. Please use options or keyword arguments.
  #{name}: ->(options) { options[:#{positional_arguments.join(" | :")}] } or
  #{name}: ->(#{positional_arguments.join(":, ")}:) {  }
  Learn more here: http://trailblazerb.org/gems/representable/upgrading-guide.html#positional-arguments
  }
          deprecated_args = []
          positional_arguments.each do |arg|
            next if arg == :index && options[:index].nil?
            deprecated_args << __options  and next if arg == :user_options# either hash or Options object.
            deprecated_args << options[arg]
          end

          return proc.(send(:exec_context, options), *deprecated_args)
        end
      end

      proc.(send(:exec_context, options), options)
    end
    private :evaluate_option_with_deprecation


    def represented
      warn "[Representable] Binding#represented is deprecated. Use options[:represented] instead."
      @represented
    end

    def compile_fragment(options)
      @represented = options[:represented]
      @parent_decorator = options[:decorator]
      super
    end

    # Parse value from doc and update the model property.
    def uncompile_fragment(options)
      @represented = options[:represented]
      @parent_decorator = options[:decorator]
      super
    end

    def get(options={}) # DISCUSS: evluate if we really need this.
      warn "[Representable] Binding#get is deprecated."
      self[:getter] ? Representable::Getter.(nil, options.merge(binding: self)) : Representable::GetValue.(nil, options.merge(binding: self))
    end
  end
end