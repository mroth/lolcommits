require 'methadone'

module Lolcommits
  module CLI
    module Util
      include Methadone::CLILogging
      #
      # change working dir to either a repo or the fs root
      #
      # TODO: This legacy could should be refactored out of the CLI logic
      # entirely.  Rather than relying on the CLI to walk to the root of a
      # git repo before invocation, we should rely upon the built-in VCS
      # functionality to detect the root of the current PWD programmatically.
      #
      # This could be handled transparently in the lib/backends library, outside
      # of the CLI.  For reference, the commands we would be using then are:
      #  - git rev-parse --show-toplevel
      #  - git rev-parse --git-dir
      #  - hg root
      #
      # This will have the added benefit of making lolcommits work with
      # git submodules (which store their info somewhere else besides PWD/.git,
      # but --git-dir will find it successfully.)
      #
      # For more details, see https://github.com/mroth/lolcommits/issues/345
      def self.change_dir_to_root_or_repo!
        debug 'Walking up dir tree'
        loop do
          cur = File.expand_path('.')
          nxt = File.expand_path('..', cur)
          if nxt == cur
            warn 'Repository root not found'
            return
          end
          return if VCSInfo.repo_root?
          Dir.chdir(nxt)
        end
      end
    end
  end
end
