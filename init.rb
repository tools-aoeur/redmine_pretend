# frozen_string_literal: true

require_relative 'lib/redmine_pretend/hooks'

Rails.autoloaders.main.ignore("#{__dir__}/lib")

Redmine::Plugin.register :redmine_pretend do
  name 'Redmine Pretend plugin'
  author 'Leonid Batizhevsky (orig)'
  description 'Plugin to pretend selected user'
  version '6.1.0'
  url 'https://github.com/tools-aoeur/redmine_pretend'

  requires_redmine version_or_higher: '6.1'
end

require_relative 'app/helpers/pretend_helper'
require_relative 'lib/redmine_pretend/application_controller_patch'
