require 'pied_piper/version'
require 'pied_piper/kernel'
require 'pry'

class PiedPiper
  class EndOfPipe; end
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def end
    EndOfPipe
  end

  def |(function)
    return object if function == EndOfPipe

    piped_result = result(function)
    PiedPiper.new(piped_result)
  end

  private

  def result(function)
    case function
    when Symbol
      @object.send(function)
    when Array
      meth, *args = function
      @object.send(meth, *args)
    when Proc
      function.call(@object, *args)
    when Method
      function.call(@object, *args)
    end
  end
end
