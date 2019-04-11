module PiedPiper::Kernel
  ::Kernel.class_eval do
    def piper(obj)
      PiedPiper.new(obj)
    end

    def p_end
      PiedPiper::EndOfPipe
    end
  end
end
