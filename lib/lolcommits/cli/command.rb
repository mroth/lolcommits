require 'methadone'
require 'clamp'

module Lolcommits
  module CLI
    # Lolcommits::CLI:Command just wraps Clamp::Command to include logging
    class Command < Clamp::Command
      include Methadone::CLILogging

      option '--debug', :flag, 'debug output',
             environment_variable: 'LOLCOMMITS_DEBUG', hidden: false # TODO: hide before v1.0 release?

      # TODO: hide [dev mode] options from default help output unless LOLCOMMITS_DEVELOPER is set
      option '--test', :flag, 'dev test mode', environment_variable: 'LOLCOMMITS_TEST'
    end
  end
end
