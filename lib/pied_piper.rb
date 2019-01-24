require "pied_piper/version"

class PiedPiper
  def initialize(obj = nil, &blk)
    if !obj.nil? && block_given?
      raise "Initialize only with parameter OR block, not both!"
    end

    @object = obj || blk.call
  end

  def |(obj, *args, &blk)
    if !obj.nil? && block_given?
      raise "Initialize only with parameter OR block, not both!"
    end
    obj = obj || blk.call
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
