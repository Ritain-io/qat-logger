require 'httparty'
require 'json'
require 'retriable'
require 'yaml'
require 'active_support/core_ext/hash/keys'

class RemoteLoggerChecker

  attr_accessor :last_time, :expected_line

  alias register_line expected_line=

  def initialize
    @test_start_ts = Time.now.iso8601(3)
  end

  def remote_logging
    @remote_logging ||= YAML.load(File.read(File.join(Dir.pwd, 'config', 'remote_logging.yml'))).symbolize_keys
  end

  def remote_logging_url
    URI::Generic.build(remote_logging)
  end

  def line_valid?
    obj = get_last_line

    Log4r::Logger.log_internal { "Line retrieved:\n#{JSON.pretty_generate obj}" }

    return false if obj == {} and expected_line != {}
    expected_line.each do |key, value|
      unless value == obj[key]
        Log4r::Logger.log_internal { "Invalid field [#{key}]: '#{obj[key]}' != '#{value}'" }
        return false
      end
    end
    return true
  end

  def get_last_line
    url = "#{remote_logging_url}/#{remote_logging[:index]}-#{Time.now.utc.strftime('%Y.%m.%d')}/_search"

    body = <<-JSON
{
  "query": {
    "bool": {
      "must": [
        {
          "query_string": {
            "default_field": "facility",
            "query": "#{remote_logging[:facility]}"
          }
        },
        {
          "range": {
            "@timestamp": {
              "from": "#{@test_start_ts}",
              "to": "#{Time.now.iso8601(3)}"
            }
          }
        }
      ]
    }
  }
}
    JSON

    Log4r::Logger.log_internal { "ES Request:\nURL:#{url}\n#{body}" }

    retries, max_retries = 0, 60
    obj                  = []

    opts = {
      body:    body,
      headers: {
        'Content-Type' => 'application/json',
        'Accept'       => 'application/json'
      }
    }

    if ENV['ES_USER'] and ENV['ES_PASSWD']
      opts[:basic_auth] = { username: ENV['ES_USER'], password: ENV['ES_PASSWD'] }
    end

    Retriable.retriable on: NoESLogFound, tries: 30, base_interval: 0.5, multiplier: 1.0, rand_factor: 0.0 do
      result = HTTParty.get(url, opts).body
      Log4r::Logger.log_internal { "Result: #{result}" }

      result = JSON.parse result

      obj = result['hits']['hits'] rescue []
      raise NoESLogFound.new("No Log was found with timestamp [#{@test_start_ts}, #{Time.now.iso8601(3)}]\nResult :#{result}") if obj == []
    end

    begin
      return obj.first['_source']
    rescue
      Log4r::Logger.log_internal { "ES Response:\n#{obj}" }
      raise
    end
  end

  class NoESLogFound < StandardError;
  end
end
