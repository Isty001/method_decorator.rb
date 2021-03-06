# MethodDecorator

Method decorator implementation for Ruby, similar to Python. Inspired by [this](https://yehudakatz.com/2009/07/11/python-decorators-in-ruby/) article.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'method_decorator.rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install method_decorator.rb

## Usage and Examples

Decorators can be used to wrap around method calls. Decoators can have their own arguments, including blocks. When the method is called, each decorator will be called in order, receiving the caller instance, the return value of the previous decorator, and the method's arguments and block.

```ruby
class Multiply < Decorator::Base
  def call(this, args, ret, &block)
    multiplier, = @decorator_args

    return multiplier * ret if ret

    multiplier * original(this, *args, &block)
  end
end

class Controller
  extend Decorator::DecoratorAware

  Multiply(2)
  Multiply(3)
  def index
    10
  end
end

puts Controller.new.index # 60
```

Decorators can have names other than the class:

```ruby
class DivideDecorator < Decorator::Base
  decorator_name :divide

  def call(this, args, ret, &block)
    #
  end
end
```
They can also receive their own block:

```ruby
class Route < Decorator::Base
  def call(this, args, ret, &block)
    @decorator_block.call
  end
end

class Controller
  extend Decorator::DecoratorAware

  Route(:get, '/') { p "hello" }
  def index
    10
  end
end

Controller.new.index  # Hello
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
