module QAT
  #CLI module from QAT::Core.
  #@since 0.1.0
  module CLI
    #Plugin namespace for CLI module from QAT::Core.
    #@since 0.1.0
    module Plugins
      #Plugin for CLI functions
      #@since 0.1.0
      module Logger

        #Function for adding the Logger module to a project. Just used for testing, does nothing.
        #@param stdout [IO] Stdout stream
        #@param opts [Hash] Options hash
        #@since 0.1.0
        def self.add_module stdout, opts
          stdout.puts 'Logger already integrated' if opts[:verbose]
        end

      end
    end
  end
end