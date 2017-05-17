require 'lolcommits/cli/command'
require 'lolcommits/cli/fatals'

module Lolcommits
  module CLI
    class DevicesCommand < Command
      def execute
        puts Platform.device_list
        info "\nSpecify capture device with --device=NAME or set $LOLCOMMITS_DEVICE"
      end
    end
  end
end
