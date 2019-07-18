require 'log4r/yamlconfigurator'
##
# Log4r::YamlConfigurator extension
class Log4r::YamlConfigurator
  ##
  # Decodes the list of configuration given by +cfg+.
  #
  # Can contain the following lists of configurations:
  # - outputters
  # - loggers
  # - logserver
  def self.decode_yaml(cfg)
    decode_pre_config(cfg['pre_config'])
    cfg['outputters'].each { |op| decode_outputter(op) } unless cfg['outputters'].nil?
    cfg['loggers'].each { |lo| decode_logger(lo) } unless cfg['loggers'].nil?
    cfg['logserver'].each { |lo| decode_logserver(lo) } unless cfg['logserver'].nil?
  end

  # Loads a stream of YAML documents from disk given by +yaml_docs+
  def self.actual_load(yaml_docs)
    log4r_config = nil
    Psych.load_stream(yaml_docs) { |doc|
      doc.has_key?('log4r_config') and log4r_config = doc['log4r_config'] and break
    }
    if log4r_config.nil?
      raise ConfigError,
            "Key 'log4r_config:' not defined in yaml documents", caller[1..-1]
    end
    decode_yaml(log4r_config)
  end
end