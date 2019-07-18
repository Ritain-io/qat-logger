module Test
  module DummyLogger
    include QAT::Logger

    def self.log_proxy
      log
    end
  end
end