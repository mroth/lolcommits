require 'lolcommits/cli/command'

require_relative 'enable'
require_relative 'disable'
require_relative 'capture'
require_relative 'history'
require_relative 'devices'
require_relative 'plugins'

module Lolcommits
  module CLI
    class LolcommitsCommand < Command
      subcommand 'enable', 'Install lolcommits for current repository', EnableCommand
      subcommand 'disable', 'Uninstall lolcommits for current repository', DisableCommand
      subcommand 'capture', 'Capture image for most recent git commit', CaptureCommand
      subcommand 'history', 'Historic archives of captured moments', HistoryCommand
      subcommand 'devices', 'Detect and list attached camera devices', DevicesCommand
      subcommand 'plugins', 'List or configure lolcommits plugins', PluginsCommand

      subcommand 'version', 'Print lolcommits version and exit' do
        def execute
          puts "lolcommits #{Lolcommits::VERSION}"
        end
      end
    end
  end
end
