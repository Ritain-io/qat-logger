#!/usr/bin/env rake
# encoding: utf-8

require 'qat/devel/tasks'
require 'erb'

namespace :qat do
	namespace :logger do
		namespace :gemfile do
			
			def load_dependencies(task)
				task.libs << File.join(File.dirname(__FILE__), 'lib')
			end
			
			def clear_reports_folder!
				mkdir_p 'public'
				rm_rf ::File.join('public', '*')
			end
			
			desc 'Run all the tests'
			task :run do
				cd 'test' do
					Cucumber::Rake::Task.new do |task|
						clear_reports_folder!
						load_dependencies(task)
					end.runner.run
				end
			end
			
			desc 'Generate example gemfile for gem usage'
			task :example do
				@gem_name = 'qat-logger'
				
				spec = Gem::Specification::load("#{@gem_name}.gemspec")
				
				@gem_version              = spec.version
				@development_dependencies = spec.development_dependencies
				
				File.write 'Gemfile.example', ERB.new(<<ERB).result
source 'https://rubygems.org'

gem '<%= @gem_name %>', '<%= @gem_version %>'
<% @development_dependencies.each do |dependency| %>gem '<%= dependency.name %>', '<%= dependency.requirements_list.reverse.join "', '"%>'
<% end %>
ERB
			end
			
			desc 'Generate default gemfile'
			task :default do
				File.write 'Gemfile.default', <<GEMFILE
source 'https://rubygems.org'

gemspec
GEMFILE
			end
		end
		
		namespace :nexus do
			
			desc 'Generate nexus configuration for deploy'
			task :config do
				File.write 'nexus', ERB.new(<<ERB).result
---
:url: <%= ENV['NEXUS_DEPLOY_URL'] %>
:authorization: Basic <%= ["#{ENV['NEXUS_DEPLOY_USER']}:#{ENV['NEXUS_DEPLOY_PASS']}"].pack('m').delete("\r\n") %>
ERB
			end
		end
	end
end