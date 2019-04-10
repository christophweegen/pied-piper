module PiedPiper::Kernel
  ::Kernel.class_eval do
    def pipe(obj = nil)
      PiedPiper.new(obj)
    end

    def pipe_end
      PiedPiper::EndOfPipe
    end
  end
end
