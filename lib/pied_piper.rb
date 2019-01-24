require 'pied_piper/version'

class PiedPiper
  def initialize(obj = nil)
    if !obj.nil? && block_given?
      raise 'Initialize only with parameter OR block, not both!'
    end

    @object = obj || yield
  end

  def |(obj, *args)
    if !obj.nil? && block_given?
      raise 'Initialize only with parameter OR block, not both!'
    end

    obj ||= yield
    return @object if obj == :end

    piped_obj = result(obj, *args)
    PiedPiper.new(piped_obj)
  end

  private

  def result(obj, *args)
    case obj
    when Symbol
      @object.send(obj, *args)
    when Proc
      obj.call(@object, *args)
    when Method
      obj.call(@object, *args)
    end
  end
end
