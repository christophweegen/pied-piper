# PiedPiper

This gem provides "Unix-like" pipe functionality in Ruby.

The inspiration for this gem were `|>` pipes and functional programming in [Elixir](https://elixir-lang.org) and another motivation was documenting my findings about Ruby, functional programming and implementing pipe-like behaviour in Ruby.

Personally I like to read `README`s of gems, which provide a lot of insights how things we're implemented and the possible pitfalls, because it's always a possibility to learn, by what others have done.

So I included the things I considered important while working on this gem.

This is maybe a lot more information that's needed to use this gem, but maybe it helps to understand, why I implemented it the way I did and gives you a deeper insight into pipes in Ruby, in case you want to implement your own piping gem :-)

After trying to introduce the same `|>` pipe operator in Ruby, which I found out isn't possible due to syntactic reasons ( without hacking the underlying C code ), I settled for another well-known pipe operator, the `|` Unix pipe operator.

If you want to read about the inspiration for the name `PiedPiper`, it's an old german fairy tale, the [Pied Piper of Hamelin](https://en.wikipedia.org/wiki/Pied_Piper_of_Hamelin), a guy who played pipe and hypnotized and lured all children out of town with his music and they were never be seen again.

Another thing worth seeing, regarding "Pied Piper" and coding, is [Silicon Valley - Company Name](https://www.youtube.com/watch?v=QJ70b-WRHlU). It's hilarious :-D ( Thanks, Michael! )

Despite the word "pipe" there's also another common thing between the fairy tale and pipes in this gem:

There's a "piper" object who lures "children" (other objects) away ( through pipes ) until they never be seen again ( are transformed into other objects ).  :-)

If you never worked with pipes, this little analogy may help, to understand what's happening.

Have fun with PiedPiper and don't let him lure you away... :-)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pied_piper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pied_piper

## Usage

First you have to initialize a piper object with another object of your choice:

```ruby
require "pied_piper"

p = PiedPiper.new("rats and kids")
```

## Shortcut

A shortcut to get a piper object anywhere you want, is shown in the following example. Only use this if your name is "Chuck Norris of Hamelin", since it "roundhouse pipes" (monkey-patches) Ruby's `Kernel` module :-D

Note: It only adds the `piper` method to `Kernel`, and a `piper` method isn't already defined above `Kernel` in the inheritance hierarchy ( where only `BasicObject` is located ) so no existing Ruby behaviour actually gets altered. More on that later.

```ruby
require 'pied_piper/kernel'

p = piper("rats and kids")
```

Once you have a piper object you can pipe it "Unix-style".

Our initial object (e.g: `"rats and kids"`), is passed around through each pipe from left to right and transformed by one of the following objects:

### Symbol/String Pipes

The easiest way to create a pipe is using symbols or strings.  This will call the method with the same name as the Symbol/String on the wrapped object:

```ruby
p = piper("rats and kids")

p | :upcase | p.end
# => "RATS AND KIDS"
```

More about `p.end` below.

### Chaining Pipes

Pipes can be chained of course:

```ruby
p = piper("rats and kids")

p | :upcase | :reverse | p.end
# => "SDIK DNA STAR"
```

### Ending Pipes

Note: Since "piping" is not a native Ruby syntax feature, rather than a method call in disguise (e.g: `"foo".|(:upcase)`), the underlying `PiedPiper` class, which wraps the initial object (e.g: `"foo"`) and on which the pipe functionality is called, is just a wrapper for the initial object which handles piping logic.

Everytime you transform an object through a pipe, there's a new object of class `PiedPiper` created, which wraps the __transformed__ inital object again (e.g: from `"foo"` to `"FOO"`).

Note the stress on "transformed", since if we want to programm in functional style we shouldn't mutate objects in place, rather than always returning a new object, without mutating the initial one.

By always returning a new object wrapped in an object of class `PiedPiper` we can build pipe-chains of arbitrary length, but at the end of each pipe-chain, the wrapped object has to be "unwrapped" again by some kind of "terminator" object.

This happens by "terminating" the pipe-chain with the `.end` method, which is defined on every piped object, or by just writing `PiedPiper::EndOfPipe` or if you have required `pied_piper/kernel` you can just write `p_end`.

```ruby
p = piper("rats and kids")

p | :upcase | p.end
# => "RATS AND KIDS"

p | :upcase | PiedPiper::EndOfPipe
# => "RATS AND KIDS"

p | :upcase | p_end # when PiedPiper::Kernel was required
# => "RATS AND KIDS"
```

It would be possible to avoid writing `p.end` at the end of the chain, by implementing the gem in another way, but that would have included to monkey-patch existing Ruby classes, since the `|` method is already implemented by some of them.

I decided against that, since I only wanted to add pipe functionality and not alter existing Ruby behaviour in any way.

Thus the `PiedPiper` class was born.

### Ruby and its Kernel module

If you want to add pipe functionality everywhere, we already talked about how to implement it above by requiring `pied_piper/kernel`.

This will provide pipe functionality on every object which has `Object` in one of its superclasses ( thus practically every object in Ruby besides `BasicObject` which is the highest class in Ruby's inheritance hierarchy ) with the least amount of monkey-patching/side-effects, since we only add one `Kernel` method named `piper` and don't alter existing behaviour.

In case you didn't know:

`Object` includes `Kernel` as a module.

Included modules can be seen in Ruby like this:

```ruby
Object.included_modules
# => [Kernel]
```

If you want to see the whole inheritance chain of a class (with superclasses and included/prepended modules) you can do this:

```ruby
Object.ancestors
# => [Object, Kernel, BasicObject]
```

Since Object `includes Kernel`, `Kernel` follows after `Object` in the ancestors array.

If `Object` would `prepend Kernel`, `Kernel` would be before `Object` in the ancestors array.

The order of included/prepended modules has implications on the method lookup, since methods defined in modules further down the inheritance hierarchy overwrite methods higher up.

This is why methods in a prepended module overwrite methods defined in a class while methods in included modules don't.

Methods who are intended to be globally available, like `puts` and `gets`, and who aren't intended to be available with an explicit receiver like `"foo".puts` are defined as private instance methods on `Kernel`.

All private instance methods can only be called with an implicit receiver (implicit `self`) in Ruby.

That's why things like this work with an implicit receiver/`self`, because we're always "inside" an object:

```ruby
puts self
# main
# nil

# implicit receiver/self for puts
puts "foo"
```

... but this doesn't, since we called `puts` on an explicit receiver:

```ruby
# explicit receiver/self for puts
self.puts "foo"
# => NoMethodError: private method `puts' called for main:Object
```

So if you want to provide functionality that should be available everywhere like `puts`, but should not be called on an object for example like `"bar".puts("foo")` or `[1,2].puts("foo")` ( because that wouldn't make sense if all these methods do is the same, putting something on the console, where a simple `puts "foo"` without receiver would be sufficient ), the usual approach is to define a private instance method on Kernel.

That's what has been done with the `piper` and `p_end` methods and can be seen in the source [here](https://github.com/christophweegen/pied-piper/blob/master/lib/pied_piper/kernel.rb) :-)

If your newly defined method on `Kernel` isn't overriding anything in `BasicObject` above, you should be able to freely add any number of new global methods (also public methods) to Ruby, without changing any existing functionality.

This is usually the only "sensible" way of monkey-patching core classes. Only adding, not altering methods.

Since everything inherits from `Object` ( and thus from `Kernel` ) in Ruby, classes or modules who have a method with the same name will simply "clobber" it with their own implementation.

In case of a collision ( for example if another gem monkey-patches the same method as you do ) you have to be a bit creative to find a non-colliding method name, or just don't use too many gems who monkey-patch things, or don't use any monkey-patching at all, since monkey-patching is usually frowned upon :-)

Problems could arise, because adding methods is still monkey-patching though (opening up existing classes again), if two gems would define the same new method on `Kernel`, so adding new methods to `Kernel` should be used sparse or better avoided at all.

Additionally what if future versions of Ruby include a `piper` method in `Kernel` or even in `BasicObject`?

Then monkey-patching these methods would introduce a lot of problems for sure :-)

That's why there's the "official" `PiedPiper` class, and the `piper` `Kernel` method only for optional convenience.

Just a bit of background information, in case you're curious how this gem was implemented or if want to implement your own piping gem by introducing monkey-patching to avoid the "pipe terminator" at the end.

Maybe you have a better idea how to implement this without a "pipe terminator" AND avoid monkey-patching.

But for now, I consider monkey-patching as cheating in order to avoid the "pipe terminator" :-D

But back to usage...

### Array Pipes

An Array, whose first element (Symbol/String) again acts as a method call on the piped object and additonal elements which act as parameters to the method call.

```ruby
p = piper("Pied Piper")

concat = [:concat, " of", " Hamelin"]

p | concat  | p.end
# => "Pied Piper of Hamelin"
```

If the first array element is a Symbol and the last is an object of class `Proc`, we can also use methods which accept blocks:

```ruby
p = piper("Pied Piper")

map_double = [:map, ->(str) { str * 2 }]
p | :split | map_double | :join | p_end
# => "PiedPiedPiperPiper"
```

It's also possible to use methods with arguments and blocks, arguments have to between the method name (first element of the array) and the last element of the array which is a block:

```ruby
p = piper("Pied Piper")

map_double_array = [:each_with_object, [], ->(str, array) { |str| array << [str * 2]}]
p | :split | map_double_array | p_end
# => [["PiedPied"], ["PiperPiper"]]
```

### Proc Object Pipes

An Object of `Proc` class which takes exactly one parameter:
- `Proc.new { |kid| ... }`
- `proc { |kid| ... }`
- `lambda { |kid| ... }`
- `->(kid) { ... }`

Procs in Ruby are essentially what is called an anonymous function or lambda in other languages.

```ruby
p = piper("Hypnotized kid")

no_happy_end = ->(kid) { kid + " was never seen again..." }

p | no_happy_end | p.end
# => "Hypnotized kid was never seen again..."
```

### Method Object Pipes

An object of the `Method` class, where the piped object will be used as the first parameter. You can pass an Array if you need additional parameters:

```ruby
class PiedPiperOfHamelin
  def self.plays_song_on_pipe(audience = "Kids", effect = "slightly")
    puts "#{audience} already feel #{effect + " "}hypnotized!"
  end
end

p = piper("You")
hypnotize = PiedPiperOfHamelin.method(:plays_song_on_pipe)

p | hypnotize | p.end
# => "You already feel slightly hypnotized!"

p | [hypnotize, "VERY"] | p.end
# => "You already feel VERY hypnotized!"
```

### Combining Pipes

Once you know the basic building blocks, you can combine them and build your own pipes of arbitrary length:

```ruby
p = piper('You')
lures = [:+, " feel"]
you = ->(str) { str + " hypnotized!" }
away = :upcase

p | lures | you | away | p.end
# => "YOU FEEL HYPNOTIZED!"
```

### Multiline Pipes

Sadly Ruby's syntax doesn't allow for totally nice multiline pipes ( at least not in a way I already found out ). Thus multiline pipes have to be written with a twist ( since they're actually just inline syntactic sugar for methods like `obj.|(arg)` under the hood:

#### With Backslashes:

In order to tell Ruby that our (inline) expression hasn't ended yet, when writing it over multiple lines, we can put a backslash at the end of a line to avoid syntax errors:

```ruby
p = piper('You')
lures = [:+, " feel"]
you = ->(str) { str + " hypnotized!" }
away = :upcase

p \
  | lures \
  | you \
  | away \
  | p.end
# => "YOU FEEL HYPNOTIZED!"
```

#### As explicit method calls:

As we already noticed that pipes `|` are simply method calls in disguise, we can explicitly call them on subsequent lines, which is valid Ruby syntax:

```ruby
p = piper('You')
lures = [:+, " feel"]
you = ->(str) { str + " hypnotized!" }
away = :upcase

p
  .|(lures)
  .|(you)
  .|(away).
  .|(p.end)
# => "YOU FEEL HYPNOTIZED!"
```

### What kind of advantages can pipes offer?

Actually we can't do anything else with pipes that we can't do with regular Ruby syntax too ( since they only build on already existing Ruby functionality and are not a totally new language feature ).

But piping objects can make some operations more clear/readable because we go from left to right in a linear fashion, instead from inside to outside like in regular function calls.

This offers advantages when for example working in "functional style" instead of using methods:

```ruby
require 'pied_piper/kernel'

class Foo
  def self.one
    -> {|x| ... }
  end
end

class Bar
  def self.two
    -> {|x| ... }
  end
end

class Baz
  def self.three
    -> {|x| ... }
  end
end

# This

Baz.three.call(Bar.two.call(Foo.one.call(x)))

# or this

foo = Foo.one.call(x)
bar = Bar.two.call(foo)
Baz.three.call(bar)

# becomes this

piper(x) | Foo.one | Bar.two | Baz.three | p_end

# or this

piper(x) \
  | Foo.one \
  | Bar.two \
  | Baz.three \
  | p_end
```

I guess you won't use these kind of functional programming in Ruby too often, since Ruby follows the philosophy of Object Oriented Programming of sending messages to objects ( i.e: calling methods on objects ) like: `obj.message`

PiedPiper is more a kind of experiment how Ruby can be modified to resemble concepts used in other programming languages like for example functional programming in [Elixir](https://elixir-lang.org) and to personally document my findings about Ruby and functional programming.

As far as I can judge Ruby does quite a good job, the flexible language constructs that Ruby has to offer, makes it still one of the nicest programming languages to work with. :-)

Since Ruby unites multiple programming paradigms, functional programming is one of them too:

The functional features Ruby has to offer for example are:

- Module/Class methods like `Foo.bar(baz)`, similar to Elixir's functions which are defined in modules too: `Foo.bar(baz)`
- Callable objects like objects of `Proc` or `Method` class.
- Blocks which can also be converted to `Proc` objects in the method signature by defining a last `&blk` parameter  ( its the `&` which converts the block into a `Proc` object, which can then be called with `blk.call` in the method body ).

What other kind of good use cases for pipes can you come up with?

If you know some, feel free to open up a pull request, so we can augment code or documentation :-)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/christophweegen/pied-piper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PiedPiper project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/christophweegen/pied-piper/blob/master/CODE_OF_CONDUCT.md).
