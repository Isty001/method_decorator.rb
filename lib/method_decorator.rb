module Decorator
  VERSION = '0.1'

  module DecoratorAware
    attr_accessor :method_decorator_map

    class << self
      attr_accessor :decorators, :registry
    end

    def method_missing(name, *args, &block)
      klass = Decorator::DecoratorAware.registry&.key(name)

      return super unless klass

      @decorators ||= []
      @decorators << [klass, args, block]
    end

    def method_added(name)
      return if @decorators.empty?

      decorators = @decorators.clone
      @decorators = []

      @method_decorator_map ||= {}
      @method_decorator_map[name] = []

      decorators.each do |klass, args, block|
        @method_decorator_map[name] << klass.new(instance_method(name), *args, &block)
      end

      class_eval "
      def #{name}(*args, &block)
        ret = nil
        self.class.method_decorator_map[:#{name}].each do |decorator|
          ret = decorator.call(self, args, ret, &block)
        end
        ret
      end"

      @decorators = []
    end
  end

  class Base
    class << self
      def decorator_name(name)
        Decorator::DecoratorAware.registry ||= {}
        Decorator::DecoratorAware.registry[self] = name.to_sym
      end

      def inherited(klass)
        Decorator::DecoratorAware.registry ||= {}
        Decorator::DecoratorAware.registry[klass] = klass.name.to_sym
      end
    end

    def initialize(method, *args, &block)
      @method = method
      @decorator_args = args
      @decorator_block = block
    end

    def original(this, *args, &block)
      @method.bind(this).call(*args, &block)
    end

    def call(this, *args, &block)
      raise NotImplementedError.new(self.class.name + '.' + __method__.to_s + ' method must be implemented')
    end
  end
end
