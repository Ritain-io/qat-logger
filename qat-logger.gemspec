#encoding: utf-8

Gem::Specification.new do |gem|
  gem.name        = 'qat-logger'
  gem.version     = '8.0.0'
  gem.summary     = %q{Ruby Logger customization used in the QAT framework, based in the Log4r gem.}
  gem.description = %q{QAT's Ruby Logger customization.}
  gem.email       = 'qat@readinessit.com'
  gem.homepage = 'https://www.readinessit.com'

  gem.metadata    = {
      'source_code_uri'   => 'https://github.com/readiness-it/qat-logger'
  }
  gem.authors = ['QAT']
  gem.license = 'GPL-3.0'

  extra_files = %w[LICENSE]
  gem.files   = Dir.glob('{lib}/**/*') + extra_files

  gem.require_paths = ['lib']

  gem.required_ruby_version = '~> 2.0'

  gem.add_dependency 'log4r', '~> 1.1'
  gem.add_dependency 'log4r-gelf', '~> 1.1'
  gem.add_dependency 'awesome_print', '~> 1.2'

  gem.add_development_dependency 'qat-devel', '~> 8.0'
  gem.add_development_dependency 'httparty', '~> 0.14'
  gem.add_development_dependency 'activesupport'
end