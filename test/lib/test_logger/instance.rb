module Test
  module TestLogger
    class Instance
      include QAT::Logger

      def log_proxy
        log
      end
    end
  end
end