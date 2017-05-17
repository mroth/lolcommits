require 'lolcommits/cli/command'
require 'lolcommits/cli/fatals'

module Lolcommits
  module CLI
    class PluginsCommand < Command
      subcommand 'list', 'List all available plugins' do
        def execute
          Configuration.new(PluginManager.init, test_mode: test?).list_plugins
        end
      end

      subcommand 'config', 'Configure a plugin' do
        parameter '[PLUGIN]', 'name of plugin to configure'
        def execute
          Fatals.die_if_not_vcs_repo!
          Configuration.new(PluginManager.init, test_mode: test?).do_configure!(plugin)
        end
      end

      subcommand 'show-config', 'show config file' do
        def execute
          Fatals.die_if_not_vcs_repo!
          puts Configuration.new(PluginManager.init, test_mode: test?)
        end
      end
    end
  end
end
