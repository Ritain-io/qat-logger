module Test
  module TestLogger
    module Random
      def self.logger
        name = "RandomLogger#{Time.now.to_i}"

        self.module_eval <<-RUBY, __FILE__, __LINE__ + 1
module #{name}
  include QAT::Logger

  def self.log_proxy
    log
  end
end
        RUBY

        Test::TestLogger::Random.const_get(name)
      end
    end
  end
end