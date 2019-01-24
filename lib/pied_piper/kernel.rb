module PiedPiper::Kernel
  ::Kernel.class_eval do
    def pipe(obj = nil, &blk)
      PiedPiper.new(obj, &blk)
    end
  end
end
