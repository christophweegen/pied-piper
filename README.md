# PiedPiper

This gem provides "Unix-like" pipe functionality in Ruby.

The inspiration for this gem were `|>` pipes and functional programming in [Elixir](https://elixir-lang.org).

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

A shortcut to get a piper object anywhere you want, is shown in the following example. Only use this if your name is "Chuck Norris of Hamelin", since it "roundhouse pipes" (monkey-patches) Ruby's `Kernel` module :-D

Note: It only adds the `piper` method to `Kernel` which isn't defined anywhere else and doesn't change existing Ruby behaviour, so using it doesn't actually make you this badass ;-)

```ruby
require 'pied_piper/kernel'

p = piper("rats and kids")
```

Once you have a piper object you can pipe it "Unix-style".

Our initial object (e.g: `"rats and kids"`), is passed around through each pipe from left to right and transformed by one of the following objects:

### Symbol/String Pipes

1. A Symbol or String, this calls a method on the piped object with the same name:

```ruby
p = piper("rats and kids")

p | :upcase | p.end
# => "RATS AND KIDS"
```

Pipes can be chained:

```ruby
p = piper("rats and kids")

p | :upcase | :reverse | p.end
# => "SDIK DNA STAR"
```

### Ending Pipes

Note: Since "piping" is not a native Ruby syntax feature, rather than a method call in disguise (e.g: `p.|(:upcase)`), the underlying `PiedPiper` class, which wraps the initial object (e.g: `"foo"`) and on which the pipe functionality is called, is just a wrapper for the initial object which handles piping logic.

Everytime you finished a pipe transformation you create a new object of class `PiedPiper`, which wraps the mutated inital object again (e.g: from `"foo"` to `"FOO"`).

We can build pipe-chains this way, but at the end of each pipe-chain, the piped object has to be "unwrapped" again by ending the pipe-chain with the `.end` method on the pipe object or by just writing `PiedPiper::EndOfPipe` or if you have required `pied_piper/kernel` you can just write `p_end`.

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

I decided against that, since I only wanted to add pipe functionality and not alter existing behaviour in any way.

Thus the `PiedPiper` class was born.

If you want to add pipe functionality everywhere, we already talked about how to implement it above under "Usage".

This will make you use pipe functionality everywhere with the least amount of side-effects, since it only adds and doesn't alter existing behaviour.

### Array Pipes

An Array, whose first element (Symbol/String) again acts as a method call on the piped object and additonal elements which act as parameters to the method call.

```ruby
p = piper("Pied Piper")

concat = [:concat, " of", " Hamelin"]

p | concat  | p.end
# => "Pied Piper of Hamelin"
```

### Proc Object Pipes

An Object of `Proc` class which takes exactly one parameter:
- `Proc.new { |kid| ... }`
- `proc { |kid| ... }`
- `lambda { |kid| ... }`
- `->(kid) { ... }`

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

p | lures | you | away | piper.end
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
  | h.end
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
  .|(h.end)
# => "YOU FEEL HYPNOTIZED!"
```

### What kind of advantages can pipes offer?

Actually we can do nothing else with pipes then we can also do with regular Ruby syntax ( since it only builds on already existing Ruby functionality and is not a totally new language feature ).

But piping objects can make some operations more clear/readable because we go from left to right in a linear fashion, instead from inside to outside like in regular function calls.

This offers advantages when for example working in "functional style" instead of using methods:

```ruby
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

# becomes this

piper(x) | Foo.one | Bar.two | Baz.three | p_end

# or

piper(x) \
  | Foo.one \
  | Bar.two \
  | Baz.three \
  | p_end
```

I guess you won't use these kind of functional programming in Ruby too often, since Ruby follows another philosophy.

PiedPiper is more a kind of experiment how Ruby can be modified to resemble concepts used in other programming languages like for example [Elixir](https://elixir-lang.org).

As far as I can judge Ruby does quite a good job, the flexible language constructs that Ruby has to offer, makes it one of the nicest programming languages to work with. :-)

What other kind of good use cases for pipes can you come up with?

If you know some ( or missing features ), feel free to open up a pull request, so we can augment code/documentation :-)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/christophweegen/pied-piper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PiedPiper project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/christophweegen/pied-piper/blob/master/CODE_OF_CONDUCT.md).
