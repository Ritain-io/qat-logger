#!/usr/bin/env rake
#encoding: utf-8

require 'qat/devel/tasks'
require 'erb'

namespace :qat do
  namespace :logger do
    namespace :gemfile do
      desc 'Generate example gemfile for gem usage'
      task :example do
        @gem_name = 'qat-logger'

        spec = Gem::Specification::load("#{@gem_name}.gemspec")

        @gem_version              = spec.version
        @development_dependencies = spec.development_dependencies

        File.write 'Gemfile.example', ERB.new(<<ERB).result
source 'http://vps316412.ovh.net:8082/nexus/repository/rit-ruby/'

gem '<%= @gem_name %>', '<%= @gem_version %>'
<% @development_dependencies.each do |dependency| %>gem '<%= dependency.name %>', '<%= dependency.requirements_list.reverse.join "', '"%>'
<% end %>
ERB
      end

      desc 'Generate default gemfile'
      task :default do
        File.write 'Gemfile.default', <<GEMFILE
source 'http://vps316412.ovh.net:8082/nexus/repository/rit-ruby/'

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