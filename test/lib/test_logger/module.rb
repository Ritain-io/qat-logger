module QAT
  module TestLogger
    include QAT::Logger

    def self.log_proxy
      log
    end
  end
end