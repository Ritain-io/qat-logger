# Qat::Logger

- Welcome to the Qat logger gem!

- This gem support different types of log formats in the following ways:
  - **Color formats;**
  - **Different channels and levels;**
  - **Logs more human readable;**
  - **File rotation;**
  - **Remote elastic search logger**

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'qat-logger'
```
And then execute:
 
    $ bundle install
 
Or install it yourself as:
 
    $ gem install qat-logger
 
 # Usage
**Color formats** - In order to use the logger colors it is necessary to have a configuration file in the project folder:
 
   - In the path ```"/config/your_environment/"``` of the project, must exist a file named ```logger.yml```. 
This is  where the color of the logs can be activated for each module. As shown in the example below:

Colors:
```ruby
'INFO'  => :green,
'WARN'  => :purple,
'ERROR' => :red,
'FATAL' => :red
```
logger.yml:
```yaml
log4r_config:

  loggers:
  - name: QAT::TestLogger
    level: INFO
    outputters:
    - qat_console_outputter
    - logfile

  outputters:
  - type: QatConsoleOutputter
    name: qat_console_outputter
    formatter:
      type: QatFormatter

  - type: FileOutputter
    name: logfile
    trunc: true
    filename: 'public/logger_testing.log'
    formatter:
      type: QatFormatter

```
**Channels and levels** - In the logger.yml file, the ```level``` defines what type of logs will be seen in the console output. 
   - Level of importance:
 ```text
 FATAL <- most important
 ERROR
 WARN
 INFO
 DEBUG <- less important
```
   
  As showed in the example, if we use the word ```INFO``` all levels above that will logged.
  To activate all levels, use the word ```ALL```.
  The formats are applied to each outputter set in the ```outputters``` field.

- **Logs more human readable** - Improves log readability for an easiest comprehension of the logs:

An object like this:
```ruby
{first: 1, second: 2, third: 3}
```

Will be seen as: 
```ruby
:first => 1,
:second => 2,
:third => 3
```

- **File rotation** - file rotation provides a way to limit the total size of the logs retained while still allowing analysis of recent events.
  - In the path ```"/config/your_environment/"``` of the project, must exist a file named ```logger_rolling_file.yml```. 
  As shown in the example below:
  
logger_rolling_file.yml:
```yaml
log4r_config:

  loggers:
  - name: QAT::TestLogger
    level: 'ALL'
    trace: yes
    outputters:
    - qat_file_outputter

  outputters:
  - type: QatFileOutputter
    name: qat_file_outputter
    trunc: true
    filename: 'public/logger_testing.log'
``` 
- **Remote elastic search logger** - remote logger provides a way of getting logs into elastic search.
    - In order to that a file named ```remote_logging.yml``` must exist in the path ```"/config/your_environment/"```:
```
host: localhost
port: 9200
scheme: http
index: tests-qat-logger
facility: QAT Remote Logger Test
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/qa-toolkit/qat-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Qat::Logger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/qa-toolkit/qat-logger/blob/master/CODE_OF_CONDUCT.md).
