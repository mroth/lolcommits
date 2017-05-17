require 'lolcommits/cli/command'
require 'lolcommits/cli/fatals'
require 'lolcommits/cli/util'

module Lolcommits
  module CLI
    class DisableCommand < Command
      def execute
        Fatals.die_if_not_vcs_repo!
        Util.change_dir_to_root_or_repo!
        Installation.do_disable
      end
    end
  end
end
