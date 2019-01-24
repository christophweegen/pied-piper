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

    result = case obj
             when Symbol
               @object.send(obj, *args)
             when Proc
               obj.call(@object, *args)
             when Method
               obj.call(@object, *args)
             end
    PiedPiper.new(result)
  end
end
