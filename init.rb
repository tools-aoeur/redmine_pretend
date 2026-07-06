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

require_relative 'lib/redmine_pretend/application_controller_patch'

# Apply patch. init.rb is re-run inside Redmine's to_prepare on every reload
# (PluginLoader#run_initializer uses `load`), while ApplicationController is a
# freshly reloaded class each cycle -- so the guarded include must live here to
# be re-applied on every reload. PretendHelper is Zeitwerk-autoloaded from
# app/helpers and referenced by constant inside the concern's `included` block.
unless ApplicationController.included_modules.include?(RedminePretend::ApplicationControllerPatch)
  ApplicationController.include RedminePretend::ApplicationControllerPatch
end
