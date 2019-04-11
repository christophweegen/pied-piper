require 'pied_piper/version'

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
      method, *args, blk = function
      case method

      when Symbol
        case blk
        when Proc
          @object.send(method, *args, &blk)
        else
          @object.send(method, *args, blk)
        end
      when Method
        method.call(@object, *args)
      end
    when Proc
      function.call(@object, *args)
    when Method
      function.call(@object, *args)
    end
  end
end
