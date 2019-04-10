# PiedPiper - Don't let him lure you away...

This gem provides "Unix-like" pipe functionality in Ruby.

Another inspiration for this gem were `|>` pipes and functional programming in [Elixir](https://elixir-lang.org).

If you want to read about the inspiration for the name `PiedPiper`, it's an old german [fairy tale](https://en.wikipedia.org/wiki/Pied_Piper_of_Hamelin), of a guy who played pipe and hypnotized and lured all children out of town with his music and they were never be seen again.

Despite the word "pipe" there's also another common thing between the fairy tale and pipes in this gem:

There's a "piper" object who lures "children" (other objects) away ( through pipes ) until they never be seen again ( are transformed into other objects ).  :-)

If you never worked with pipes, this little analogy may help to understand what's happening.

Have fun with PiedPiper and don't let him lure you away :-)

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

piper = PiedPiper.new("rats and children")
```

A shortcut to get a piper object anywhere you want, is shown in the following example. Only use this if your name is "Chuck Norris of Hamelin", since it "roundhouse pipes" (monkey-patches) Ruby's `Kernel` module :-D

```ruby
require 'pied_piper/kernel'

piper = pipe("rats and children")
```

Once you have a piper object you can pipe it "Unix-style".

Our initial object (e.g: `"rats and children"`), is passed around through each pipe from left to right and transformed by one of the following objects:

### Symbol/String Pipes

1. A Symbol or String, this calls a method on the piped object with the same name:

```ruby
p = pipe("rats and children")
p | :upcase | p.end
# => "RATS AND CHILDREN"
```

Note: Since "piping" is not a native Ruby syntax feature, rather than a method call in disguise (e.g: `p.|(:upcase)`), the underlying `PiedPiper` class, which wraps the initial object (e.g: `"foo"`) and on which the pipe method is called, is just a wrapper for the initial object which handles piping logic.

Everytime you "pipe" you create a new object of class `PiedPiper`, which wraps the mutated inital object again (e.g: from `"foo"` to `"FOO"`).

At the end of each pipe-chain, the piped object has to be "unwrapped" again by ending the pipe-chain with the `.end` method on the pipe object or by just writing `PiedPiper::EndOfPipe` or if you have required `pied_piper/kernel` you can just write `pipe_end`.

```ruby
p = pipe("rats and children")

p | :upcase | p.end
# => "RATS AND CHILDREN"

p | :upcase | PiedPiper::EndOfPipe
# => "RATS AND CHILDREN"

p | :upcase | pipe_end # when PiedPiper::Kernel was required
# => "RATS AND CHILDREN"
```

### Array Pipes

An Array, whose first element (Symbol/String) again acts as a method call on the piped object and additonal elements which act as parameters to the method call.

```ruby
p = pipe("Pied Piper")

concat = [:concat, " of", " Hamelin"]

p | concat  | p.end
# => "Pied Piper of Hamelin"
```

### Proc Object Pipes

An Object of `Proc` class which takes exactly one parameter:
- `Proc.new { |child| ... }`
- `proc { |child| ... }`
- `lambda { |child| ... }`
- `->(child) { ... }`

```ruby
p = pipe("Hypnotized child")

no_happy_end = ->(child) { child + " was never seen again..." }

p | no_happy_end | p.end
# => "Hypnotized child was never seen again..."
```

### Method Object Pipes

An object of the `Method` class, where the piped object will be used as the first parameter. You can pass an Array if you need additional parameters:

```ruby
class PiedPiperOfHamelin
  def self.plays_song_on_pipe(audience = "Children", effect = "slightly")
    puts "#{audience} feel already #{effect + " "}hypnotized!"
  end
end

p = pipe("You")
hypnotize = PiedPiperOfHamelin.method(:plays_song_on_pipe)

p | hypnotize | p.end
# => "You already feel slightly hypnotized!"

p | [hypnotize, "VERY"] | p.end
# => "You already feel VERY hypnotized!"
```

### Combining Pipes

Once you know the basic building blocks, you can combine them and build your own pipes of arbitrary length:

```ruby
piper = pipe('You')
lures = [:+, " feel"]
you = ->(str) { str + " hypnotized!" }
away = :upcase

piper | lures | you | away | piper.end
# => "YOU FEEL HYPNOTIZED!"
```

### Multiline Pipes

Sadly Ruby's syntax doesn't allow for totally nice multiline pipes ( at least not in a way I already found out ). Thus multiline pipes have to be written like this ( since they're actually just inline syntactic sugar for methods like `obj.|(arg)` under the hood:

```ruby
piper = pipe('You')
lures = [:+, " feel"]
you = ->(str) { str + " hypnotized!" }
away = :upcase

piper
  .|(lures)
  .|(you)
  .|(away).
  .|(h.end)
# => "YOU FEEL HYPNOTIZED!"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/christophweegen/pied-piper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PiedPiper project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/christophweegen/pied-piper/blob/master/CODE_OF_CONDUCT.md).
