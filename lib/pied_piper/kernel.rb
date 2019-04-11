require 'pied_piper'

module PiedPiper::Kernel
  ::Kernel.class_eval do
    private

    def piper(obj)
      PiedPiper.new(obj)
    end

    def p_end
      PiedPiper::EndOfPipe
    end
  end
end
