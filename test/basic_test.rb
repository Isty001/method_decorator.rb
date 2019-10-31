require_relative './test.rb'


class Multiple < Decorator::Base
  def call(this, ret, args, &block)
    multiplier, = @decorator_args

    return multiplier * ret if ret

    multiplier * original(this, *args, &block)
  end
end

class DivideDecorator < Decorator::Base
  decorator_name :divide

  def call(this, ret, args, &block)
    divider, = @decorator_args

    return ret / divider if ret

    original(this, *args, &block) / divider
  end
end

class Controller
  extend Decorator::DecoratorAware

  Multiple(2)
  Multiple(3)
  def index
    10
  end

  divide(2)
  divide(5)
  def users
    100
  end
end

class DecoratorTest < MiniTest::Test
  def test_class_name_decorator
    controller = Controller.new

    assert_equal(60, controller.index)
  end

  def test_custom_name_decorator
    controller = Controller.new

    assert_equal(10, controller.users)
  end
end
