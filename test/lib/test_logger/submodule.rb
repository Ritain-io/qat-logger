module QAT
  module TestLogger
    class Submodule
      include QAT::Logger

      def self.log_proxy
        log
      end
    end
  end
end