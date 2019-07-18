module Test
  module TestLogger
    class Singleton
      include QAT::Logger

      def self.log_proxy
        log
      end
    end
  end
end